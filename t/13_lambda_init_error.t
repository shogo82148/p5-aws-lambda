use strict;
use warnings;
use utf8;

use Test::More;
use Test::TCP;
use HTTP::Server::PSGI;
use FindBin;
use AWS::Lambda::Bootstrap;
use AWS::Lambda::Context;
use Test::Deep;
use Test::SharedFork;
use Plack::Request;
use JSON::XS qw/decode_json/;

my $app_server = Test::TCP->new(
    code => sub {
        my $port = shift;
        my $server = HTTP::Server::PSGI->new(
            host    => "127.0.0.1",
            port    => $port,
        );
        $server->run(sub {
            my $env = shift;
            my $req = Plack::Request->new($env);
            is $req->method, "POST", "http method";
            my $body = $req->body;
            my $response = decode_json(<$body>);
            cmp_deeply $response, {errorMessage=>"some error 😨", errorType=>'error'}, "response";
            my $res = $req->new_response(200);
            $res->finalize;
        });
    },
    wait_port_retry => 40,
    wait_port_sleep => 0.1,
);

my $bootstrap = AWS::Lambda::Bootstrap->new(
    handler     => "echo.handle",
    runtime_api => "example.com",
    task_root   => "$FindBin::Bin/test_handlers",
    runtime_api => "127.0.0.1:" . $app_server->port,
);

my $error = "some error 😨";
$bootstrap->lambda_init_error($error);
$app_server->stop;

done_testing;
