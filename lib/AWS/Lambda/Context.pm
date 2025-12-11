package AWS::Lambda::Context;
use 5.026000;
use strict;
use warnings;

use Time::HiRes qw(time);

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my %args;
    if (@_ == 1 && ref $_[0] eq 'HASH') {
        %args = %{$_[0]};
    } else {
        %args = @_;
    }
    my $deadline_ms = $args{deadline_ms} // die 'deadline_ms is required';
    my $invoked_function_arn = $args{invoked_function_arn} // '';
    my $aws_request_id = $args{aws_request_id} // '';
    my $trace_id = $args{trace_id};
    my $tenant_id = $args{tenant_id};
    my $self = bless +{
        deadline_ms          => +$deadline_ms,
        invoked_function_arn => $invoked_function_arn,
        aws_request_id       => $aws_request_id,
        trace_id             => $trace_id,
        tenant_id            => $tenant_id,
    }, $class;

    return $self;
}

sub get_remaining_time_in_millis {
    my $self = shift;
    return $self->{deadline_ms} - time() * 1000;
}

sub function_name {
    return $ENV{AWS_LAMBDA_FUNCTION_NAME} // die 'function_name is not found';
}

sub function_version {
    return $ENV{AWS_LAMBDA_FUNCTION_VERSION} // die 'function_version is not found';
}

sub invoked_function_arn {
    my $self = shift;
    return $self->{invoked_function_arn};
}

sub memory_limit_in_mb {
    return +$ENV{AWS_LAMBDA_FUNCTION_MEMORY_SIZE} // die 'memory_limit_in_mb is not found';
}

sub aws_request_id {
    my $self = shift;
    return $self->{aws_request_id};
}

sub log_group_name {
    return $ENV{AWS_LAMBDA_LOG_GROUP_NAME} // die 'log_group_name is not found';
}

sub log_stream_name {
    return $ENV{AWS_LAMBDA_LOG_STREAM_NAME} // die 'log_stream_name is not found';
}

sub identity {
    return undef; # TODO
}

sub client_context {
    return undef; # TODO
}

sub tenant_id {
    my $self = shift;
    return $self->{tenant_id};
}

1;
=encoding utf-8

=head1 NAME

AWS::Lambda::Context - It's Perl port of the AWS Lambda Context.

=head1 SYNOPSIS

    sub handle {
        my ($payload, $context) = @_;
        # $context is an instance of AWS::Lambda::Context
        my $result = {
            # The name of the Lambda function.
            function_name => $context->function_name,

            # The version of the function.
            function_version => $context->function_version,
            
            # The Amazon Resource Name (ARN) used to invoke the function.
            # Indicates if the invoker specified a version number or alias.
            invoked_function_arn => $context->invoked_function_arn,

            # The amount of memory configured on the function.
            memory_limit_in_mb => $context->memory_limit_in_mb,

            # The identifier of the invocation request.
            aws_request_id => $context->aws_request_id,

            # The log group for the function.
            log_group_name => $context->log_group_name,

            # The log stream for the function instance.
            log_stream_name => $context->log_stream_name,

            # The tenant id for the function.
            tenant_id => $context->tenant_id,
        };
        return $result;
    }

=head1 LICENSE

The MIT License (MIT)

Copyright (C) ICHINOSE Shogo.

=head1 AUTHOR

ICHINOSE Shogo E<lt>shogo82148@gmail.comE<gt>

=cut
