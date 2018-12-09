package AWS::Lambda::Context;
use 5.026000;
use strict;
use warnings;

use Time::HiRes qw(time);

sub new {
    my $class = shift;
    my %args = @_;
    my $deadline_ms = $args{deadline_ms} // die 'deadine_ms is required';
    my $invoked_function_arn = $args{invoked_function_arn} // die 'invoked_function_arn is required';
    my $aws_request_id = $args{aws_request_id} // 'aws_request_id is required';
    my $self = bless +{
        deadline_ms => +$deadline_ms,
        invoked_function_arn => $invoked_function_arn,
        aws_request_id => $aws_request_id,
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

1;
