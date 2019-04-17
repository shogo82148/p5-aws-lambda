use strict;
use warnings;
use utf8;

use Test::More;
use Test::TCP;
use HTTP::Server::PSGI;
use FindBin;
use AWS::Lambda::Bootstrap;
use Test::Deep;

my $app_server = Test::TCP->new(
    code => sub {
        my $port = shift;
        my $server = HTTP::Server::PSGI->new(
            host    => "127.0.0.1",
            port    => $port,
        );
        $server->run(sub {
            [
                200,
                [
                    'Content-Type' => 'application/json',
                    'Lambda-Runtime-Aws-Request-Id' => '8476a536-e9f4-11e8-9739-2dfe598c3fcd',
                    'Lambda-Runtime-Deadline-Ms' => '1542409706888',
                    'Lambda-Runtime-Invoked-Function-Arn' => 'arn:aws:lambda:us-east-2:123456789012:function:custom-runtime',
                    'Lambda-Runtime-Trace-Id' => ' Root=1-5bef4de7-ad49b0e87f6ef6c87fc2e700;Parent=9a9197af755a6419;Sampled=1',
                ],
                [ '{"key1":"a", "key2":"b", "key3":"c"}' ],
            ]
        });
    },
    max_wait => 10, # seconds
);

my $bootstrap = AWS::Lambda::Bootstrap->new(
    handler     => "echo.handle",
    runtime_api => "example.com",
    task_root   => "$FindBin::Bin/test_handlers",
    runtime_api => "127.0.0.1:" . $app_server->port,
);

my ($payload, $context) = $bootstrap->lambda_next;
cmp_deeply $payload, {key1=>"a", key2=>"b", key3=>"c"}, "payload";

is $context->aws_request_id, '8476a536-e9f4-11e8-9739-2dfe598c3fcd', "request id";
is $context->invoked_function_arn, 'arn:aws:lambda:us-east-2:123456789012:function:custom-runtime', 'invoked function arn';

done_testing;
