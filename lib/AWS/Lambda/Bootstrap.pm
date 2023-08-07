package AWS::Lambda::Bootstrap;
use 5.026000;
use utf8;
use strict;
use warnings;
use HTTP::Tiny;
use JSON::XS qw/decode_json encode_json/;
use Try::Tiny;
use AWS::Lambda;
use AWS::Lambda::Context;
use AWS::Lambda::ResponseWriter;
use Scalar::Util qw(blessed);
use Exporter 'import';

our @EXPORT = ('bootstrap');

sub bootstrap {
    my $handler = shift;
    my $bootstrap = AWS::Lambda::Bootstrap->new(
        handler => $handler,
    );
    $bootstrap->handle_events;
}

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my %args;
    if (@_ == 1 && ref $_[0] eq 'HASH') {
        %args = %{$_[0]};
    } else {
        %args = @_;
    }

    my $api_version = '2018-06-01';
    my $env_handler = $args{handler} // $ENV{'_HANDLER'} // die '$_HANDLER is not found';
    my ($handler, $function) = split(/[.]/, $env_handler, 2);
    my $runtime_api = $args{runtime_api} // $ENV{'AWS_LAMBDA_RUNTIME_API'} // die '$AWS_LAMBDA_RUNTIME_API is not found';
    my $task_root = $args{task_root} // $ENV{'LAMBDA_TASK_ROOT'} // die '$LAMBDA_TASK_ROOT is not found';
    my $self = bless +{
        task_root      => $task_root,
        handler        => $handler,
        function_name  => $function,
        runtime_api    => $runtime_api,
        api_version    => $api_version,
        next_event_url => "http://${runtime_api}/${api_version}/runtime/invocation/next",
        http           => HTTP::Tiny->new,
    }, $class;
    return $self;
}

sub handle_events {
    my $self = shift;
    $self->_init or return;
    while(1) {
        $self->handle_event;
    }
}

sub _init {
    my $self = shift;
    if (my $func = $self->{function}) {
        return $func;
    }

    my $task_root = $self->{task_root};
    my $handler = $self->{handler};
    my $name = $self->{function_name};
    return try {
        package main;
        require "${task_root}/${handler}.pl";
        my $f = main->can($name) // die "handler $name is not found";
        $self->{function} = $f;
    } catch {
        $self->lambda_init_error($_);
        $self->{function} = sub {};
        undef;
    };
}

sub handle_event {
    my $self = shift;
    $self->_init or return;
    my ($payload, $context) = $self->lambda_next;
    my $response = try {
        local $AWS::Lambda::context = $context;
        local $ENV{_X_AMZN_TRACE_ID} = $context->{trace_id};
        $self->{function}->($payload, $context);
    } catch {
        my $err = $_;
        print STDERR "$err";
        $self->lambda_error($err, $context);
        bless {}, 'AWS::Lambda::ErrorSentinel';
    };
    my $ref = ref($response);
    if ($ref eq 'AWS::Lambda::ErrorSentinel') {
        return;
    }
    if ($ref eq 'CODE') {
        $self->lambda_response_streaming($response, $context);
    } else {
        $self->lambda_response($response, $context);
    }
    return 1;
}

sub lambda_next {
    my $self = shift;
    my $resp = $self->{http}->get($self->{next_event_url});
    if (!$resp->{success}) {
        die "failed to retrieve the next event: $resp->{status} $resp->{reason}";
    }
    my $h = $resp->{headers};
    my $payload = decode_json($resp->{content});
    return $payload, AWS::Lambda::Context->new(
        deadline_ms          => $h->{'lambda-runtime-deadline-ms'},
        aws_request_id       => $h->{'lambda-runtime-aws-request-id'},
        invoked_function_arn => $h->{'lambda-runtime-invoked-function-arn'},
        trace_id             => $h->{'lambda-runtime-trace-id'},
    );
}

sub lambda_response {
    my $self = shift;
    my ($response, $context) = @_;
    my $runtime_api = $self->{runtime_api};
    my $api_version = $self->{api_version};
    my $request_id = $context->aws_request_id;
    my $url = "http://${runtime_api}/${api_version}/runtime/invocation/${request_id}/response";
    my $resp = $self->{http}->post($url, {
        content => encode_json($response),
    });
    if (!$resp->{success}) {
        die "failed to response of execution: $resp->{status} $resp->{reason}";
    }
}

sub lambda_response_streaming {
    my $self = shift;
    my ($response, $context) = @_;
    my $runtime_api = $self->{runtime_api};
    my $api_version = $self->{api_version};
    my $request_id = $context->aws_request_id;
    my $url = "http://${runtime_api}/${api_version}/runtime/invocation/${request_id}/response";
    my $writer = undef;
    try {
        $response->(sub {
            my $content_type = shift;
            $writer = AWS::Lambda::ResponseWriter->new(
                response_url => $url,
                http         => $self->{http},
            );
            $writer->_request($content_type);
            return $writer;
        });
    } catch {
        my $err = $_;
        print STDERR "$err";
        if ($writer) {
            $writer->_close_with_error($err);
        } else {
            $self->lambda_error($err, $context);
        }
    };
    if ($writer) {
        my $response = $writer->_handle_response;
        if (!$response->{success}) {
            die "failed to response of execution: $response->{status} $response->{reason}";
        }
    }
}

sub lambda_error {
    my $self = shift;
    my ($error, $context) = @_;
    my $runtime_api = $self->{runtime_api};
    my $api_version = $self->{api_version};
    my $request_id = $context->aws_request_id;
    my $url = "http://${runtime_api}/${api_version}/runtime/invocation/${request_id}/error";
    my $type = blessed($error) // "Error";
    my $resp = $self->{http}->post($url, {
        content => encode_json({
            errorMessage => "$error",
            errorType => "$type",
        }),
    });
    if (!$resp->{success}) {
        die "failed to send error of execution: $resp->{status} $resp->{reason}";
    }
}

sub lambda_init_error {
    my $self = shift;
    my $error = shift;
    my $runtime_api = $self->{runtime_api};
    my $api_version = $self->{api_version};
    my $url = "http://${runtime_api}/${api_version}/runtime/init/error";
    my $type = blessed($error) // "Error";
    my $resp = $self->{http}->post($url, {
        content => encode_json({
            errorMessage => "$error",
            errorType => "$type",
        }),
    });
    if (!$resp->{success}) {
        die "failed to send error of execution: $resp->{status} $resp->{reason}";
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

AWS::Lambda::Bootstrap - the bootrap script for AWS Lambda Custom Runtime.

=head1 SYNOPSIS

Save the following script as C<bootstrap>, and then zip it with your perl script.
Now, you can start using Perl in AWS Lambda!

    #!perl
    use strict;
    use warnings;
    use utf8;
    use AWS::Lambda::Bootstrap;

    bootstrap(@ARGV);

Prebuild Perl Runtime Layer includes the C<bootstrap> script.
So, if you use the Layer, no need to include the C<bootstrap> script into your zip.
See L<AWS::Lambda> for more details.

=head1 DESCRIPTION

The format of the handler is following.

    sub handle {
        my ($payload, $context) = @_;
        # handle the event here.
        my $result = {};
        return $result;
    }

C<$context> is an instance of L<AWS::Lambda::Context>.

=head1 RESPONSE STREAMING

It also supports L<response streaming|https://docs.aws.amazon.com/lambda/latest/dg/configuration-response-streaming.html>.

    sub handle {
        my ($payload, $context) = @_;
        return sub {
            my $responder = shift;
            my $writer = $responder->('application/json');
            $writer->write('{"foo": "bar"}');
            $writer->close;
        };
    }

=head1 LICENSE

The MIT License (MIT)

Copyright (C) ICHINOSE Shogo.

=head1 AUTHOR

ICHINOSE Shogo E<lt>shogo82148@gmail.comE<gt>

=cut
