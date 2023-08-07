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
    listen => 1,
    code => sub {
        my $sock = shift;
        my $server = HTTP::Server::PSGI->new(
            listen_sock => $sock,
        );
        $server->run(sub {
            my $env = shift;
            my $req = Plack::Request->new($env);
            is $req->method, "POST", "http method";
            my $body = $req->body;
            my $response = decode_json(<$body>);
            cmp_deeply $response, {errorMessage=>"some error 😨", errorType=>'Error'}, "response";
            my $res = $req->new_response(200);
            $res->finalize;
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

my $error = "some error 😨";
$bootstrap->lambda_init_error($error);
$app_server->stop;

done_testing;
