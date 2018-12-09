use strict;
use warnings;
use utf8;

use Test::More;
use Test::Deep;

use FindBin;
use lib "$FindBin::Bin/lib";
use BootstrapMock;
use AWS::Lambda::Context;

my $payload = +{
    key1 => 1,
    key2 => 2,
    key3 => 3,
};
my $response;
my $context;
my $dummy_context = time;

my $bootstrap = BootstrapMock->new(
    handler     => "echo.handle",
    runtime_api => "example.com",
    task_root   => "$FindBin::Bin/test_handlers",
    lambda_next => sub {
        return $payload, $dummy_context;
    },
    lambda_response => sub {
        my $self = shift;
        $response = shift;
        $context = shift;
    },
);

$bootstrap->handle_event;
cmp_deeply $response, $payload, "echo handler";
is $context, $dummy_context, "context";

done_testing;
