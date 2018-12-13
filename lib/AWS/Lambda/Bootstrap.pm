package AWS::Lambda::Bootstrap;
use 5.026000;
use utf8;
use strict;
use warnings;
use HTTP::Tiny;
use JSON::XS qw/decode_json encode_json/;
use Try::Tiny;
use AWS::Lambda::Context;
use Scalar::Util qw(blessed);

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
        $self->{function}->($payload, $context);
    } catch {
        $self->lambda_error($_, $context);
        bless {}, 'AWS::Lambda::ErrorSentinel';
    };
    if (ref($response) eq 'AWS::Lambda::ErrorSentinel') {
        return;
    }
    $self->lambda_response($response, $context);
    return 1;
}

sub lambda_next {
    my $self = shift;
    my $resp = $self->{http}->get($self->{next_event_url});
    if (!$resp->{success}) {
        die 'failed to retrieve the next event: $resp->{status} $resp->{reason}';
    }
    my $h = $resp->{headers};
    my $payload = decode_json($resp->{content});
    return $payload, AWS::Lambda::Context->new(
        deadline_ms    => $h->{'lambda-runtime-deadline-ms'},
        aws_request_id => $h->{'lambda-runtime-aws-request-id'},
        invoked_function_arn => $h->{'lambda-runtime-invoked-function-arn'},
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
        die 'failed to response of execution: $resp->{status} $resp->{reason}';
    }
}

sub lambda_error {
    my $self = shift;
    my ($error, $context) = @_;
    my $runtime_api = $self->{runtime_api};
    my $api_version = $self->{api_version};
    my $request_id = $context->aws_request_id;
    my $url = "http://${runtime_api}/${api_version}/runtime/invocation/${request_id}/error";
    my $resp = $self->{http}->post($url, {
        content => encode_json({
            errorMessage => "$error",
            errorType => blessed($error) // "error",
        }),
    });
    if (!$resp->{success}) {
        die 'failed to send error of execution: $resp->{status} $resp->{reason}';
    }
}

sub lambda_init_error {
    my $self = shift;
    my $error = shift;
    my $runtime_api = $self->{runtime_api};
    my $api_version = $self->{api_version};
    my $url = "http://${runtime_api}/${api_version}/runtime/init/error";
    my $resp = $self->{http}->post($url, {
        content => encode_json({
            errorMessage => "$error",
            errorType => blessed($error) // "error",
        }),
    });
    if (!$resp->{success}) {
        die 'failed to send error of execution: $resp->{status} $resp->{reason}';
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

AWS::Lambda::Bootstrap - It's new $module

=head1 SYNOPSIS

    use AWS::Lambda::Bootstrap;

=head1 DESCRIPTION


=head1 LICENSE

The MIT License (MIT)

Copyright (C) Ichinose Shogo.

=head1 AUTHOR

Ichinose Shogo E<lt>shogo82148@gmail.comE<gt>

=cut
