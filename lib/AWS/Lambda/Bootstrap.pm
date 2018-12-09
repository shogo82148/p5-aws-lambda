package AWS::Lambda::Bootstrap;
use 5.026000;
use strict;
use warnings;

sub new {
    my $class = shift;
    my %args = @_;

    my $env_handler = $ENV{'_HANDLER'} // die '$_HANDLER is not found';
    my ($handler, $func) = split(/[.]/, $env_handler, 2);
    my $aws_lambda_runtime_api = $ENV{'AWS_LAMBDA_RUNTIME_API'} // die '$AWS_LAMBDA_RUNTIME_API is not found';
    my $self = bless +{
        task_root => $ENV{'LAMBDA_TASK_ROOT'} // die '$LAMBDA_TASK_ROOT is not found',
        handler   => $handler,
        func      => $func,
        aws_lambda_runtime_api => $aws_lambda_runtime_api,
        next_event_url => "http://${aws_lambda_runtime_api}/2018-06-01/runtime/invocation/next",
    }, $class;

    return $self;
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
