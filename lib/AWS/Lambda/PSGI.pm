package AWS::Lambda::PSGI;
use 5.026000;
use utf8;
use strict;
use warnings;
use URI::Escape;
use Plack::Util;
use bytes ();
use MIME::Base64;
use JSON::Types;
use Encode;
use Try::Tiny;
use AWS::Lambda;
use Scalar::Util qw(reftype);
use JSON::XS qw(encode_json);

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
 
    my $self;
    if (@_ == 1 && ref $_[0] eq 'HASH') {
        $self = bless {%{$_[0]}}, $class;
    } else {
        $self = bless {@_}, $class;
    }

    if (!defined $self->{invoke_mode}) {
        my $mode = $ENV{PERL5_LAMBDA_PSGI_INVOKE_MODE}
            || $ENV{AWS_LWA_INVOKE_MODE} # for compatibility with https://github.com/awslabs/aws-lambda-web-adapter
            || "BUFFERED";
        $self->{invoke_mode} = uc $mode;
    }

    if (!defined $self->{allowed_hosts}) {
        $self->{allowed_hosts} = $ENV{PERL5_LAMBDA_PSGI_ALLOWED_HOSTS};
    }
    $self->{allowed_hosts} = _parse_allowed_hosts($self->{allowed_hosts});
 
    return $self;
}

# returns an array ref of lower-cased host names, or undef if any host is allowed.
# $hosts is an array ref or a comma-separated string.
sub _parse_allowed_hosts {
    my $hosts = shift;
    return undef unless defined $hosts;
    my @hosts = ref $hosts eq 'ARRAY' ? @$hosts : split /,/, $hosts;
    @hosts = grep { $_ ne '' } map { my $h = lc($_ // ''); $h =~ s/^\s+|\s+$//g; $h =~ s/\.$//; $h } @hosts;
    return @hosts ? \@hosts : undef;
}

# returns true if the Host header of $env is one of the allowed hosts.
sub _is_allowed_host {
    my ($self, $env) = @_;
    my $allowed = $self->{allowed_hosts} or return 1;
    my $host = $env->{HTTP_HOST} // '';

    # strip the port. an IPv6 address is in brackets, e.g. "[2001:db8::1]:8080".
    if ($host =~ /^(\[[0-9A-Fa-f:.]+\])(?::[0-9]+)?$/) {
        $host = $1;
    } elsif ($host =~ /^([A-Za-z0-9.-]+)(?::[0-9]+)?$/) {
        $host = $1;
    } else {
        return 0;
    }
    $host = lc $host;
    $host =~ s/\.$//; # "example.com." is "example.com"

    for my $pattern (@$allowed) {
        if ($pattern =~ /^\.(.+)$/) {
            # ".example.com" matches example.com and its subdomains.
            my $domain = $1;
            return 1 if $host eq $domain || $host =~ /\Q$pattern\E$/;
        } else {
            return 1 if $host eq $pattern;
        }
    }
    return 0;
}

sub _bad_request {
    return [400, ['Content-Type' => 'text/plain'], ['Bad Request']];
}

sub prepare_app { return }

sub app {
    return $_[0]->{app} if scalar(@_) == 1;
    return $_[0]->{app} = scalar(@_) == 2 ? $_[1] : [ @_[1..$#_ ]];
}

sub to_app {
    my $self = shift;
    $self->prepare_app;
    return sub { $self->call(@_) };
}

sub wrap {
    my($self, $app, @args) = @_;

    # Lambda function runs as reverse proxy backend,
    # but Plack::Middleware::ReverseProxy is not enabled here.
    # format_input sets REMOTE_ADDR, psgi.url_scheme, HTTPS and SERVER_PORT from the Lambda event.
    # The X-Forwarded-* headers that ReverseProxy reads are not trustworthy:
    # the AWS front ends do not set X-Forwarded-Host, X-Forwarded-Server and X-Forwarded-HTTPS at all.

    if (ref $self) {
        $self->{app} = $app;
    } else {
        $self = $self->new({ app => $app, @args });
    }
    return $self->to_app;
}

sub call {
    my($self, $env, $ctx) = @_;

    # $ctx is added by #26
    # fall back to $AWS::Lambda::context because of backward compatibility.
    $ctx ||= $AWS::Lambda::context;

    if ($self->{invoke_mode} eq "RESPONSE_STREAM") {
        my $input = $self->_format_input_v2($env, $ctx);
        $input->{'psgi.streaming'} = Plack::Util::TRUE;
        my $res = $self->_is_allowed_host($input) ? $self->app->($input) : _bad_request();
        return $self->_handle_response_stream($res);
    } else {
        my $input = $self->format_input($env, $ctx);
        my $res = $self->_is_allowed_host($input) ? $self->app->($input) : _bad_request();
        return $self->format_output($res);
    }
}

sub format_input {
    my ($self, $payload, $ctx) = @_;
    if (my $context = $payload->{requestContext}) {
        if ($context->{elb}) {
            # Application Load Balancer https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html
            return $self->_format_input_v1($payload, $ctx);
        }
    }
    if (my $version = $payload->{version}) {
        if ($version =~ /^1[.]/) {
            # API Gateway for REST https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
            return $self->_format_input_v1($payload, $ctx);
        }
        if ($version =~ /^2[.]/) {
            # API Gateway for HTTP https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html
            return $self->_format_input_v2($payload, $ctx);
        }
    }
    return $self->_format_input_v1($payload, $ctx);
}

sub _format_input_v1 {
    my ($self, $payload, $ctx) = @_;
    my $env = {};

    # merge queryStringParameters and multiValueQueryStringParameters
    my $query = {
        %{$payload->{queryStringParameters} // {}},
        %{$payload->{multiValueQueryStringParameters} // {}},
    };
    my @params;
    while (my ($key, $value) = each %$query) {
        if (ref($value) eq 'ARRAY') {
            for my $v (@$value) {
                push @params, "$key=$v";
            }
        } else {
            push @params, "$key=$value";
        }
    }
    $env->{QUERY_STRING} = join '&', @params;

    # merge headers and multiValueHeaders
    my $headers = {
        %{$payload->{headers} // {}},
        %{$payload->{multiValueHeaders} // {}},
    };
    while (my ($key, $value) = each %$headers) {
        next if _has_underscore($key);
        $key =~ s/-/_/g;
        $key = uc $key;
        if ($key !~ /^(?:CONTENT_LENGTH|CONTENT_TYPE)$/) {
            $key = "HTTP_$key";
        }
        if (ref $value eq "ARRAY") {
            $value = join ", ", @$value;
        }
        $env->{$key} = $value;
    }

    $env->{'psgi.version'}      = [1, 1];
    $env->{'psgi.errors'}       = *STDERR;
    $env->{'psgi.run_once'}     = Plack::Util::FALSE;
    $env->{'psgi.multithread'}  = Plack::Util::FALSE;
    $env->{'psgi.multiprocess'} = Plack::Util::FALSE;
    $env->{'psgi.streaming'}    = Plack::Util::FALSE;
    $env->{'psgi.nonblocking'}  = Plack::Util::FALSE;
    $env->{'psgix.harakiri'}    = Plack::Util::TRUE;
    $env->{'psgix.input.buffered'} = Plack::Util::TRUE;

    # inject the request id that compatible with Plack::Middleware::RequestId
    if ($ctx) {
        $env->{'psgix.request_id'} = $ctx->aws_request_id;
        $env->{'HTTP_X_REQUEST_ID'} = $ctx->aws_request_id;
    }

    my $body = encode_utf8($payload->{body} // '');
    if ($payload->{isBase64Encoded}) {
        $body = decode_base64 $body;
    }
    open my $input, "<", \$body;
    $env->{REQUEST_METHOD} = $payload->{httpMethod};
    $env->{'psgi.input'} = $input;
    $env->{CONTENT_LENGTH} //= bytes::length($body);
    $env->{REQUEST_URI} = $payload->{path};
    if ($env->{QUERY_STRING}) {
        $env->{REQUEST_URI} .= '?' . $env->{QUERY_STRING};
    }
    $env->{PATH_INFO} = URI::Escape::uri_unescape($payload->{path});

    $env->{SCRIPT_NAME} = '';
    my $requestContext = $payload->{requestContext};
    if ($requestContext) {
        my $path = $requestContext->{path};
        my $stage = $requestContext->{stage};
        if ($stage && $path && $path ne $payload->{path}) {
            $env->{SCRIPT_NAME} = "/$stage";
        }
    }

    if ($requestContext && $requestContext->{elb}) {
        # Application Load Balancer has no sourceIp in the event.
        # It sets X-Forwarded-For, X-Forwarded-Proto and X-Forwarded-Port instead.
        # Read them by their exact names, so that a header such as "X_Forwarded_For" cannot be used.
        my $xff = _last_header_value($payload, 'x-forwarded-for');
        if (defined $xff && $xff =~ /([^,\s]+)\s*$/) {
            $env->{REMOTE_ADDR} = $1;
        }
        my $proto = _last_header_value($payload, 'x-forwarded-proto') // '';
        $env->{'psgi.url_scheme'} = lc $proto eq 'https' ? 'https' : 'http';
        $env->{HTTPS} = 'ON' if $env->{'psgi.url_scheme'} eq 'https';
        my $port = _last_header_value($payload, 'x-forwarded-port') // '';
        $env->{SERVER_PORT} = $port =~ /^\s*([0-9]+)\s*$/ ? $1
            : $env->{'psgi.url_scheme'} eq 'https' ? 443 : 80;
    } else {
        # API Gateway REST API accepts only HTTPS.
        my $source_ip = $requestContext && $requestContext->{identity} && $requestContext->{identity}{sourceIp};
        if (defined $source_ip) {
            $env->{REMOTE_ADDR} = $source_ip;
        }
        $env->{'psgi.url_scheme'} = 'https';
        $env->{HTTPS} = 'ON';
        $env->{SERVER_PORT} = 443;
    }

    return $env;
}

# Header names that contain "_" are dropped, as Apache httpd and nginx do by default.
# "-" becomes "_" in the PSGI env, so a client could send "X_Forwarded_For" or "x_amzn_oidc_identity"
# and overwrite "X-Forwarded-For" or "x-amzn-oidc-identity" that the AWS front end sets.
sub _has_underscore {
    my $key = shift;
    return index($key, '_') >= 0;
}

# returns the last value of the header $name in the payload.
# $name must be lower case, and it is compared with the header names as is,
# i.e. "x_forwarded_for" does not match "x-forwarded-for".
sub _last_header_value {
    my ($payload, $name) = @_;
    my $value;
    for my $headers ($payload->{headers}, $payload->{multiValueHeaders}) {
        next if ref $headers ne 'HASH';
        for my $key (sort keys %$headers) {
            next if lc $key ne $name;
            my $v = $headers->{$key};
            $v = $v->[-1] if ref $v eq 'ARRAY';
            $value = $v if defined $v;
        }
    }
    return $value;
}

sub _format_input_v2 {
    my ($self, $payload, $ctx) = @_;
    my $env = {};

    $env->{QUERY_STRING} = $payload->{rawQueryString};

    my $headers = $payload->{headers} // {};
    while (my ($key, $value) = each %$headers) {
        next if _has_underscore($key);
        $key =~ s/-/_/g;
        $key = uc $key;
        if ($key !~ /^(?:CONTENT_LENGTH|CONTENT_TYPE)$/) {
            $key = "HTTP_$key";
        }
        $env->{$key} = $value;
    }

    $env->{'psgi.version'}      = [1, 1];
    $env->{'psgi.errors'}       = *STDERR;
    $env->{'psgi.run_once'}     = Plack::Util::FALSE;
    $env->{'psgi.multithread'}  = Plack::Util::FALSE;
    $env->{'psgi.multiprocess'} = Plack::Util::FALSE;
    $env->{'psgi.streaming'}    = Plack::Util::FALSE;
    $env->{'psgi.nonblocking'}  = Plack::Util::FALSE;
    $env->{'psgix.harakiri'}    = Plack::Util::TRUE;
    $env->{'psgix.input.buffered'} = Plack::Util::TRUE;

    # inject the request id that compatible with Plack::Middleware::RequestId
    if ($ctx) {
        $env->{'psgix.request_id'} = $ctx->aws_request_id;
        $env->{'HTTP_X_REQUEST_ID'} = $ctx->aws_request_id;
    }

    my $body = encode_utf8($payload->{body} // '');
    if ($payload->{isBase64Encoded}) {
        $body = decode_base64 $body;
    }
    open my $input, "<", \$body;
    $env->{'psgi.input'} = $input;
    $env->{CONTENT_LENGTH} //= bytes::length($body);
    my $requestContext = $payload->{requestContext};
    $env->{REQUEST_METHOD} = $requestContext->{http}{method};
    $env->{REQUEST_URI} = $payload->{rawPath};
    if ($env->{QUERY_STRING}) {
        $env->{REQUEST_URI} .= '?' . $env->{QUERY_STRING};
    }
    $env->{PATH_INFO} = $requestContext->{http}{path};
    $env->{SCRIPT_NAME} = '';

    # API Gateway HTTP API and Lambda Function URLs accept only HTTPS.
    my $source_ip = $requestContext->{http}{sourceIp};
    if (defined $source_ip) {
        $env->{REMOTE_ADDR} = $source_ip;
    }
    $env->{'psgi.url_scheme'} = 'https';
    $env->{HTTPS} = 'ON';
    $env->{SERVER_PORT} = 443;
    return $env;
}

sub format_output {
    my ($self, $response) = @_;
    my ($status, $headers, $body) = @$response;

    my $singleValueHeaders = {};
    my $multiValueHeaders = {};
    Plack::Util::header_iter($headers, sub {
        my ($k, $v) = @_;
        $singleValueHeaders->{lc $k} = string $v;
        push @{$multiValueHeaders->{lc $k} //= []}, string $v;
    });

    my $content = '';
    if (reftype($body) eq 'ARRAY') {
        $content = join '', grep defined, @$body;
    } else {
        local $/ = \4096;
        while (defined(my $buf = $body->getline)) {
            $content .= $buf;
        }
        $body->close;
    }

    my $type = $singleValueHeaders->{'content-type'} // 'application/octet-stream';
    my $isBase64Encoded = $type !~ m(^text/.*|application/(:?json|javascript|xml))i;
    if ($isBase64Encoded) {
        $content = encode_base64 $content, '';
    } else {
        $content = try {
            # is valid utf-8 string? try to decode as utf-8.
            decode_utf8($content, Encode::FB_CROAK | Encode::LEAVE_SRC);
        } catch {
            # it looks not utf-8 encoding. fallback to base64 encoding.
            $isBase64Encoded = 1;
            encode_base64 $content, '';
        };
    }

    return +{
        isBase64Encoded => bool $isBase64Encoded,
        headers => $singleValueHeaders,
        multiValueHeaders => $multiValueHeaders,
        statusCode => number $status,
        body => string $content,
    }
}

sub _handle_response_stream {
    my ($self, $response) = @_;
    if (reftype($response) ne "CODE") {
        my $orig = $response;
        $response = sub {
            my $responder = shift;
            $responder->($orig);
        };
    }

    return sub {
        my $lambda_responder = shift;
        my $psgi_responder = sub {
            my $response = shift;
            my ($status, $headers, $body) = @$response;

            # write the prelude.
            my $writer = $lambda_responder->("application/vnd.awslambda.http-integration-response");
            my $prelude = encode_json($self->_format_response_stream($status, $headers));
            $prelude .= "\x00\x00\x00\x00\x00\x00\x00\x00";
            $writer->write($prelude) or die "failed to write prelude: $!";

            # write the body.
            if (!defined $body) {
                # the caller will write the body.
                return $writer;
            }
            if (reftype($body) eq 'ARRAY') {
                # array-ref
                for my $chunk (@$body) {
                    $writer->write($chunk) or die "failed to write chunk: $!";
                }
            } else {
                # IO::Handle-like object
                local $/ = \4096;
                while (defined(my $chunk = $body->getline)) {
                    $writer->write($chunk) or die "failed to write chunk: $!";
                }
            }
            $writer->close or die "failed to close writer: $!";
            return;
        };
        $response->($psgi_responder);
    };
}

sub _format_response_stream {
    my ($self, $status, $headers) = @_;
    my $headers_hash = {};
    my $cookies = [];

    Plack::Util::header_iter($headers, sub {
        my ($k, $v) = @_;
        $k = lc $k;
        if ($k eq 'set-cookie') {
            push @$cookies, string $v;
        } elsif (exists $headers_hash->{$k}) {
            $headers_hash->{$k} = ", $v";
        } else {
            $headers_hash->{$k} = string $v;
        }
    });

    return +{
        statusCode => number $status,
        headers    => $headers_hash,
        cookies    => $cookies,
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

AWS::Lambda::PSGI - It translates event of Lambda Proxy Integrations in API Gateway and 
Application Load Balancer into L<PSGI>.

=head1 SYNOPSIS

Add the following script into your Lambda code archive.

    use utf8;
    use warnings;
    use strict;
    use AWS::Lambda::PSGI;

    my $app = require "$ENV{'LAMBDA_TASK_ROOT'}/app.psgi";
    my $func = AWS::Lambda::PSGI->wrap($app);

    sub handle {
        return $func->(@_);
    }

    1;

And then, L<Set up Lambda Proxy Integrations in API Gateway|https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html> or
L<Lambda Functions as ALB Targets|https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html>

=head1 DESCRIPTION

=head2 Streaming Response

L<AWS::Lambda::PSGI> supports L<response streaming|https://docs.aws.amazon.com/lambda/latest/dg/configuration-response-streaming.html>.
The function urls's invoke mode is configured as C<"RESPONSE_STREAM">, and Lambda environment variable "PERL5_LAMBDA_PSGI_INVOKE_MODE" is set to C<"RESPONSE_STREAM">.

    ExampleApi:
        Type: AWS::Serverless::Function
        Properties:
            FunctionUrlConfig:
                AuthType: NONE
                InvokeMode: RESPONSE_STREAM
            Environment:
                Variables:
                PERL5_LAMBDA_PSGI_INVOKE_MODE: RESPONSE_STREAM
            # (snip)

In this mode, the PSGI server accepts L<Delayed Response and Streaming Body|https://metacpan.org/pod/PSGI#Delayed-Response-and-Streaming-Body>.

    my $app = sub {
        my $env = shift;
    
        return sub {
            my $responder = shift;
            $responder->([ 200, ['Content-Type' => 'text/plain'], [ "Hello World" ] ]);
        };
    };

An application MAY omit the third element (the body) when calling the responder.

    my $app = sub {
        my $env = shift;
    
        return sub {
            my $responder = shift;
            my $writer = $responder->([ 200, ['Content-Type' => 'text/plain'] ]);
            $writer->write("Hello World");
            $writer->close;
        };
    };

=head2 Request ID

L<AWS::Lambda::PSGI> injects the request id that compatible with L<Plack::Middleware::RequestId>.

    env->{'psgix.request_id'} # It is same value with $context->aws_request_id

=head2 Request Headers

Request headers whose names contain an underscore (C<_>), such as C<X_Forwarded_For>, are dropped,
as Apache httpd and nginx do by default.
In the PSGI environment C<-> in header names becomes C<_>,
so C<X_Forwarded_For> and C<X-Forwarded-For> would both be C<HTTP_X_FORWARDED_FOR>,
and a client could overwrite a header that the AWS front end sets,
such as C<X-Forwarded-For> or C<X-Amzn-Oidc-Identity> of Application Load Balancer.
This is a change from the earlier versions, which passed these headers to the app.
Use C<-> instead of C<_> in the names of your own headers.

=head2 Remote Address

L<AWS::Lambda::PSGI> sets C<REMOTE_ADDR> from the Lambda event, not from the C<X-Forwarded-For> header.

=over 4

=item API Gateway REST API

C<REMOTE_ADDR> is C<requestContext.identity.sourceIp>.

=item API Gateway HTTP API and Lambda Function URLs

C<REMOTE_ADDR> is C<requestContext.http.sourceIp>.

=item Application Load Balancer

Its events have no C<sourceIp>, so C<REMOTE_ADDR> is the last address in the C<X-Forwarded-For> header
that the load balancer sets.
Only the header named exactly C<X-Forwarded-For> is used; a header such as C<X_Forwarded_For> is not.
This address is the client's only while the load balancer appends to C<X-Forwarded-For>,
which is the default of the C<routing.http.xff_header_processing.mode> attribute.
In the C<preserve> mode the client can set it to any value,
and in the C<remove> mode C<REMOTE_ADDR> is not set.

=back

This is a change from the earlier versions, which took C<REMOTE_ADDR> from the last address in C<X-Forwarded-For>.
If another proxy, such as Amazon CloudFront, is in front of API Gateway or Lambda Function URLs,
C<sourceIp> is the address of that proxy, not the viewer's.
If you trust that proxy and want the viewer's address,
take it from C<X-Forwarded-For> in your app,
for example with L<Plack::Middleware::ReverseProxy> or L<Plack::Middleware::XForwardedFor> and the proxy's addresses.

=head2 URL Scheme and Port

L<AWS::Lambda::PSGI> sets C<psgi.url_scheme>, C<HTTPS> and C<SERVER_PORT> from the Lambda event.

=over 4

=item API Gateway and Lambda Function URLs

They accept only HTTPS, so C<psgi.url_scheme> is C<https>, C<HTTPS> is C<ON> and C<SERVER_PORT> is C<443>.

=item Application Load Balancer

They come from the headers named exactly C<X-Forwarded-Proto> and C<X-Forwarded-Port> that the load balancer sets.
A header such as C<X_Forwarded_Proto> is not used.

=back

=head2 Allowed Hosts

Application Load Balancer passes the C<Host> header that the client sends to the function as is,
unless a listener rule checks it, and its events have no other host name.
So C<HTTP_HOST>, and the URLs that the app builds from it (for example the links in password reset emails),
can be any value that the client chooses.

Set the host names that the app serves with the C<allowed_hosts> option of C<new> or C<wrap>,
or with the Lambda environment variable C<PERL5_LAMBDA_PSGI_ALLOWED_HOSTS> (comma-separated).
A request whose C<Host> header is not one of them gets C<400 Bad Request>, and the app is not called.

    my $func = AWS::Lambda::PSGI->wrap($app, allowed_hosts => ['example.com', '.example.net']);

    # or in the SAM template
    Environment:
        Variables:
            PERL5_LAMBDA_PSGI_ALLOWED_HOSTS: example.com,.example.net

The port in the C<Host> header is ignored, and host names are compared case-insensitively.
A name that starts with a dot, such as C<.example.net>, matches C<example.net> and all its subdomains.
The option applies to all event types, so include every host name that clients use,
such as the custom domain names of API Gateway or the Lambda Function URL.
If neither is set, any C<Host> header is accepted, as in the earlier versions.

=head2 Reverse Proxy

Earlier versions of C<wrap> enabled L<Plack::Middleware::ReverseProxy>. It no longer does.
The values that it derived from the C<X-Forwarded-For>, C<X-Forwarded-Proto> and C<X-Forwarded-Port> headers
now come from the Lambda event as described above.
The AWS front ends do not set C<X-Forwarded-Host>, C<X-Forwarded-Server> and C<X-Forwarded-HTTPS>.
Their values come from the client as is,
so they no longer change C<HTTP_HOST>, C<SERVER_PORT> or C<psgi.url_scheme>.
The app still receives all these headers as request headers.
If a proxy that you trust sets them, enable L<Plack::Middleware::ReverseProxy> in your own app.

=head1 LICENSE

The MIT License (MIT)

Copyright (C) ICHINOSE Shogo.

=head1 AUTHOR

ICHINOSE Shogo E<lt>shogo82148@gmail.comE<gt>

=cut
