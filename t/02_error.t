use strict;
use warnings;
use utf8;

use Test::More;
use Test::Deep;

use FindBin;
use lib "$FindBin::Bin/lib";
use BootstrapMock;
use AWS::Lambda::Context;

my $error;
my $bootstrap = BootstrapMock->new(
    handler     => "echo.handle",
    runtime_api => "example.com",
    task_root   => "$FindBin::Bin/test_handlers",
    lambda_next => sub {
        return +{
            key1 => 1,
            key2 => 2,
            key3 => 3,
        }, AWS::Lambda::Context->new;
    },
    lambda_error => sub {
        my $self = shift;
        $error = shift;
    },
);

$bootstrap->handle_event;
is $error, "some error";
done_testing;
