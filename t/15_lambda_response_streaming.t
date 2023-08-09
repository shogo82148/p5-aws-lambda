use strict;
use warnings;
use utf8;

use Test::More;
use Test::TCP;
use Starman::Server;
use FindBin;
use AWS::Lambda::Bootstrap;
use AWS::Lambda::Context;
use Test::Deep;
use Test::SharedFork;
use Plack::Request;
use JSON::XS qw/decode_json/;

sub slurp {
    my $fh = shift;
    my $data = "";
    while ($fh->read(my $buf, 4096)) {
        $data .= $buf;
    }
    return $data;
}

my $app_server = Test::TCP->new(
    code => sub {
        my $port = shift;
        my $server = Starman::Server->new;
        my $app = sub {
            my $env = shift;
            my $req = Plack::Request->new($env);
            my $headers = $req->headers;
            my $body = slurp($req->body);

            is $req->method, "POST", "http method is POST";
            is $headers->header('Lambda-Runtime-Function-Response-Mode'), "streaming", "streaming is enabled";
            is $body, '{"key1":"a","key2":"b","key3":"c"}', "response body is correct";

            my $res = $req->new_response(200);
            $res->content_type("application/json");
            $res->body('{}');
            $res->finalize;
        };
        $server->run($app, {
            port => $port, host => '127.0.0.1',
        });
    },
    max_wait => 10, # seconds
);

my $bootstrap = AWS::Lambda::Bootstrap->new(
    handler     => "streaming.handle",
    runtime_api => "example.com",
    task_root   => "$FindBin::Bin/test_handlers",
    runtime_api => "127.0.0.1:" . $app_server->port,
);

my $response = sub {
    my $responder = shift;
    my $writer = $responder->("application/json");
    $writer->write('{"key1":"a","key2":"b",');
    $writer->write('"key3":"c"}');
    $writer->close;
};
my $context = AWS::Lambda::Context->new(
    deadline_ms => 1542409706888,
    aws_request_id => "8476a536-e9f4-11e8-9739-2dfe598c3fcd",
    invoked_function_arn => 'arn:aws:lambda:us-east-2:123456789012:function:custom-runtime',
);
$bootstrap->lambda_response_streaming($response, $context);
$app_server->stop;

done_testing;
