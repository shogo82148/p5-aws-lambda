use strict;
use warnings;
use utf8;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";
use BootstrapMock;
use AWS::Lambda::Context;

my $error;
my $bootstrap = BootstrapMock->new(
    handler     => "error.handle",
    runtime_api => "example.com",
    task_root   => "$FindBin::Bin/test_handlers",
    lambda_next => sub {
        return +{
            key1 => 1,
            key2 => 2,
            key3 => 3,
        }, undef;
    },
    lambda_error => sub {
        my $self = shift;
        $error = shift;
    },
);

ok !$bootstrap->handle_event;
like $error, qr/some error/;
done_testing;
