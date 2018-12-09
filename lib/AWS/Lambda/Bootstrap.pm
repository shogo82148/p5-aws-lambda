package AWS::Lambda::Bootstrap;
use 5.026000;
use utf8;
use strict;
use warnings;
use HTTP::Tiny;
use JSON::XS qw/decode_json encode_json/;
use Try::Tiny;
use AWS::Lambda::Context;

sub new {
    my $class = shift;
    my %args = @_;

    my $api_version = '2018-06-01';
    my $env_handler = $args{handler} // $ENV{'_HANDLER'} // die '$_HANDLER is not found';
    my ($handler, $function) = split(/[.]/, $env_handler, 2);
    my $runtime_api = $args{runtime_api} // $ENV{'AWS_LAMBDA_RUNTIME_API'} // die '$AWS_LAMBDA_RUNTIME_API is not found';
    my $task_root = $args{task_root} // $ENV{'LAMBDA_TASK_ROOT'} // die '$LAMBDA_TASK_ROOT is not found';
    my $self = bless +{
        task_root      => $task_root,
        handler        => $handler,
        function       => $function,
        runtime_api    => $runtime_api,
        api_version    => $api_version,
        next_event_url => "http://${runtime_api}/${api_version}/runtime/invocation/next",
        http           => HTTP::Tiny->new,
    }, $class;
    return $self;
}

sub task_root { shift->{task_root} }
sub handler   { shift->{handler} }
sub function  { shift->{function} }
sub hander_function {
    my $self = shift;
    if (scalar(@_) == 0) {
        return $self->{hander_function};
    } else {
        $self->{hander_function} = $_[0];
    }
}

sub handle_events {
    my $self = shift;
    while(1) {
        $self->handle_event;
    }
}

sub init {
    my $self = shift;
    my $task_root = $self->task_root;
    my $handler = $self->handler;
    my $function = $self->function;

    try {
        package main;
        require "${task_root}/${handler}.pl";
        my $f = main->can($function) // die "handler $function is not found";
        $self->hander_function($f);
    } catch {
        $self->lambda_init_error($_);
        die "initialize error: $_";
    };
}

sub handle_event {
    my $self = shift;
    my $func = $self->hander_function;
    if (!$func) {
        $self->init;
        $func = $self->hander_function;
    }
    my ($payload, $context) = $self->lambda_next;
    my $response = try {
        $func->($payload, $context);
    } catch {
        $self->lambda_erorr($_);
        bless {}, 'AWS::Lambda::ErrorSentinel';
    };
    if (ref($response) eq 'AWS::Lambda::ErrorSentinel') {
        return
    }
    $self->lambda_response($response, $context)
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

sub lambda_erorr {
    my $self = shift;
}

sub lambda_init_error {
    my $self = shift;
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
