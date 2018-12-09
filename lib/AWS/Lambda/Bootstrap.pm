package AWS::Lambda::Bootstrap;
use 5.026000;
use strict;
use warnings;

my $api_version = '2018-06-01';

sub new {
    my $class = shift;
    my %args = @_;

    my $env_handler = $ENV{'_HANDLER'} // die '$_HANDLER is not found';
    my ($handler, $function) = split(/[.]/, $env_handler, 2);
    my $aws_lambda_runtime_api = $ENV{'AWS_LAMBDA_RUNTIME_API'} // die '$AWS_LAMBDA_RUNTIME_API is not found';
    my $self = bless +{
        task_root => $ENV{'LAMBDA_TASK_ROOT'} // die '$LAMBDA_TASK_ROOT is not found',
        handler   => $handler,
        function  => $function,
        aws_lambda_runtime_api => $aws_lambda_runtime_api,
        next_event_url => "http://${aws_lambda_runtime_api}/${api_version}/runtime/invocation/next",
    }, $class;

    return $self;
}

sub run {
    my $self = shift;
    $self->init;
    while(1) {
        my ($payload, $context) = $self->next;
        $self->handle($payload, $context);
    }
}

sub init {
    my $self = shift;
}

sub next {
    my $self = shift;
    return +{};
}

sub handle {
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
