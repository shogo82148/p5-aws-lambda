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
use Plack::Middleware::ReverseProxy;
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
 
    return $self;
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

    # Lambda function runs as reverse proxy backend.
    # So, we always enable ReverseProxy middleware.
    $app = Plack::Middleware::ReverseProxy->wrap($app);

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
        my $res = $self->app->($input);
        return $self->_handle_response_stream($res);
    } else {
        my $input = $self->format_input($env, $ctx);
        my $res = $self->app->($input);
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

    return $env;
}

sub _format_input_v2 {
    my ($self, $payload, $ctx) = @_;
    my $env = {};

    $env->{QUERY_STRING} = $payload->{rawQueryString};

    my $headers = $payload->{headers} // {};
    while (my ($key, $value) = each %$headers) {
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

=head1 LICENSE

The MIT License (MIT)

Copyright (C) ICHINOSE Shogo.

=head1 AUTHOR

ICHINOSE Shogo E<lt>shogo82148@gmail.comE<gt>

=cut
