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

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
 
    my $self;
    if (@_ == 1 && ref $_[0] eq 'HASH') {
        $self = bless {%{$_[0]}}, $class;
    } else {
        $self = bless {@_}, $class;
    }
 
    $self;
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
    if (ref $self) {
        $self->{app} = $app;
    } else {
        $self = $self->new({ app => $app, @args });
    }
    return $self->to_app;
}

sub call {
    my($self, $env) = @_;
    my $input = $self->format_input($env);
    my $res = $self->app->($input);
    return $self->format_output($res);
}

# API Gateway https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
# Application Load Balancer https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html
sub format_input {
    my $self = shift;
    my $payload = shift;
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

    my $body = $payload->{body};
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

    if (defined $payload->{ requestContext } and defined $payload->{ requestContext }->{ stage }) {
      $env->{SCRIPT_NAME} = "/$payload->{ requestContext }->{ stage }";
    } else {
      $env->{SCRIPT_NAME} = '';
    }

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
    if (ref $body eq 'ARRAY') {
        $content = join '', grep defined, @$body;
    } else {
        local $/ = \4096;
        while (defined(my $buf = $body->getline)) {
            $content .= $buf;
        }
        $body->close;
    }

    my $type = $singleValueHeaders->{'content-type'};
    my $isBase64Encoded = $type !~ m(^text/.*|application/(:?json|javascript|xml))i;
    if ($isBase64Encoded) {
        $content = encode_base64 $content, '';
    } else {
        try {
            # is valid utf-8 string?
            decode_utf8($content, Encode::FB_CROAK | Encode::LEAVE_SRC);
        } catch {
            $isBase64Encoded = 1;
            $content = encode_base64 $content, '';
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

1;
__END__

=encoding utf-8

=head1 NAME

AWS::Lambda::PSGI - It translates enevt of Lambda Proxy Integrations in API Gateway and 
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
        my $payload = shift;
        return $func->($payload);
    }

    1;

And then, L<Set up Lambda Proxy Integrations in API Gateway|https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html> or
L<Lambda Functions as ALB Targets|https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html>

=head1 LICENSE

The MIT License (MIT)

Copyright (C) Ichinose Shogo.

=head1 AUTHOR

Ichinose Shogo E<lt>shogo82148@gmail.comE<gt>

=cut
