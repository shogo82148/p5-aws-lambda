use strict;
use warnings;
use utf8;

use Test::More;
use FindBin;
use JSON::XS qw/decode_json encode_json/;
use File::Slurp qw(slurp);
use Plack::Request;
use Test::Deep;
use JSON::Types;

use AWS::Lambda::PSGI;

my $app = AWS::Lambda::PSGI->new;

subtest "API Gateway GET Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/apigateway-get-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'GET', 'method';
    is $req->content, '', 'content';
    is $req->request_uri, '/foo%20/bar', 'request uri';
    is $req->path_info, '/foo /bar', 'path info';
    is $req->query_string, 'query=hoge&query=fuga', 'query string';
    is $req->header('Header-Name'), 'Value1, Value2', 'header';
};

subtest "API Gateway POST Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/apigateway-post-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    is $req->content_type, 'application/json', 'content-type';
    is $req->content, '{"hello":"world"}', 'content';
    is $req->request_uri, '/', 'request uri';
    is $req->path_info, '/', 'path info';
    is $req->query_string, '', 'query string';
};

subtest "API Gateway Base64 encoded POST Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/apigateway-base64-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';

    # You have to add 'application/octet-stream' to binary media types.
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-payload-encodings-configure-with-console.html
    is $req->content_type, 'application/octet-stream', 'content-type';
    is $req->content, '{"hello":"world"}', 'content';
    is $req->request_uri, '/', 'request uri';
    is $req->path_info, '/', 'path info';
    is $req->query_string, '', 'query string';
};

subtest "ALB GET Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/alb-get-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'GET', 'method';
    is $req->content, '', 'content';
    is $req->request_uri, '/foo/bar', 'request uri';
    is $req->path_info, '/foo/bar', 'path info';
    is $req->query_string, 'query=hoge&query=fuga', 'query string';
    is $req->header('Header-Name'), 'Value1, Value2', 'header';
};

subtest "ALB POST Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/alb-post-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    is $req->content_type, 'application/json', 'content-type';
    is $req->content, '{"hello":"world"}', 'content';
    is $req->request_uri, '/', 'request uri';
    is $req->path_info, '/', 'path info';
    is $req->query_string, '', 'query string';
};

subtest "ALB POST Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/alb-base64-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    is $req->content_type, 'application/octet-stream', 'content-type';
    is $req->content, '{"hello":"world"}', 'content';
    is $req->request_uri, '/foo/bar', 'request uri';
    is $req->path_info, '/foo/bar', 'path info';
    is $req->query_string, '', 'query string';
};

subtest "plain text response" => sub {
    my $response = [
        200,
        [
            'Content-Type' => 'text/plain',
            'Header-Name' => 'value1',
            'header-name' => 'value2',
        ],
        [
            "Hello",
            "World",
        ]
    ];
    my $res = $app->format_output($response);
    cmp_deeply $res, {
        isBase64Encoded => bool 0,
        headers => {
            'content-type' => 'text/plain',
            'header-name' => 'value2',
        },
        multiValueHeaders => {
            'content-type' => ['text/plain'],
            'header-name' => ['value1', 'value2'],
        },
        statusCode => 200,
        body => "HelloWorld",
    };
};

subtest "plain text response" => sub {
    my $response = [
        200,
        [
            'Content-Type' => 'application/octet-stream',
        ],
        [
            '{"hello":"world"}',
        ]
    ];
    my $res = $app->format_output($response);
    cmp_deeply $res, {
        isBase64Encoded => bool 1,
        headers => {
            'content-type' => 'application/octet-stream',
        },
        multiValueHeaders => {
            'content-type' => ['application/octet-stream'],
        },
        statusCode => 200,
        body => "eyJoZWxsbyI6IndvcmxkIn0=",
    };
};

done_testing;
