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
my $dummy_context = AWS::Lambda::Context->new(
    deadline_ms          => 1000,
    aws_request_id       => '8476a536-e9f4-11e8-9739-2dfe598c3fcd',
    invoked_function_arn => 'arn:aws:lambda:us-east-2:123456789012:function:custom-runtime',
    trace_id             => "Root=1-5bef4de7-ad49b0e87f6ef6c87fc2e700;Parent=9a9197af755a6419;Sampled=1",
);

my $bootstrap = BootstrapMock->new(
    handler     => "streaming.handle",
    runtime_api => "example.com",
    task_root   => "$FindBin::Bin/test_handlers",
    lambda_next => sub {
        return $payload, $dummy_context;
    },
    lambda_response_streaming => sub {
        my $self = shift;
        $response = shift;
        $context = shift;
    },
);

ok $bootstrap->handle_event;
is ref($response), "CODE", "echo handler";
is $context, $dummy_context, "context";

done_testing;
