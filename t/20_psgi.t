use strict;
use warnings;
use utf8;

use Test::More;
use FindBin;
use JSON::XS qw/decode_json encode_json/;
use File::Slurp qw(slurp);
use Plack::Request;
use Test::Deep qw(cmp_deeply);
use Test::Warn;
use JSON::Types;
use Encode;

use AWS::Lambda::Context;
use AWS::Lambda::PSGI;

sub slurp_fh {
    my $fh = $_[0];
    local $/;
    my $v = <$fh>;
    defined $v ? $v : '';
}

my $app = AWS::Lambda::PSGI->new;

subtest "API Gateway GET Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/apigateway-get-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'GET', 'method';
    my $content;
    warning_is { $content = slurp_fh($req->input) } undef, 'no warning';
    is $content, '', 'content';
    is $req->request_uri, '/foo%20/bar?query=hoge&query=fuga', 'request uri';
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
    my $content;
    warning_is { $content = slurp_fh($req->input) } undef, 'no warning';
    is $content, '{"hello":"world"}', 'content';
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
    my $content;
    warning_is { $content = slurp_fh($req->input) } undef, 'no warning';
    is $content, '{"hello":"world"}', 'content';
    is $req->request_uri, '/', 'request uri';
    is $req->path_info, '/', 'path info';
    is $req->query_string, '', 'query string';
};

subtest "API Gateway v2 GET Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/apigateway-v2-get-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'GET', 'method';
    my $content;
    warning_is { $content = slurp_fh($req->input) } undef, 'no warning';
    is $content, '', 'content';
    is $req->request_uri, '/my/path?parameter1=value1&parameter1=value2&parameter2=value', 'request uri';
    is $req->path_info, '/my/path', 'path info';
    is $req->query_string, 'parameter1=value1&parameter1=value2&parameter2=value', 'query string';
    is $req->header('Header1'), 'value1,value2', 'header';
};

subtest "API Gateway v2 POST Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/apigateway-v2-post-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    my $content;
    warning_is { $content = slurp_fh($req->input) } undef, 'no warning';
    is $content, '{"hello":"world"}', 'content';
    is $req->request_uri, '/my/path', 'request uri';
    is $req->path_info, '/my/path', 'path info';
    is $req->query_string, '', 'query string';
};

subtest "API Gateway v2 base64 Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/apigateway-v2-base64-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    my $content;
    warning_is { $content = slurp_fh($req->input) } undef, 'no warning';
    is $content, '{"hello":"world"}', 'content';
    is $req->request_uri, '/my/path', 'request uri';
    is $req->path_info, '/my/path', 'path info';
    is $req->query_string, '', 'query string';
};

subtest "ALB GET Request" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/alb-get-request.json"));
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'GET', 'method';
    is slurp_fh($req->input), '', 'content';
    is $req->request_uri, '/foo/bar?query=hoge&query=fuga', 'request uri';
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
    is slurp_fh($req->input), '{"hello":"world"}', 'content';
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
    is slurp_fh($req->input), '{"hello":"world"}', 'content';
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
            encode_utf8("こんにちは世界"),
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
        body => "HelloWorldこんにちは世界",
    };
    diag encode_json $res;
};

subtest "binary response" => sub {
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
    diag encode_json $res;
};

subtest "IO::Handle-like response" => sub {
    open my $f, "<", \"HelloWorld";
    my $response = [
        200,
        [
            'Content-Type' => 'text/plain',
        ],
        $f,
    ];
    my $res = $app->format_output($response);
    cmp_deeply $res, {
        isBase64Encoded => bool 0,
        headers => {
            'content-type' => 'text/plain',
        },
        multiValueHeaders => {
            'content-type' => ['text/plain'],
        },
        statusCode => 200,
        body => "HelloWorld",
    };
    diag encode_json $res;
};

subtest "EUC-JP encoded response" => sub {
    my $response = [
        200,
        [
            'Content-Type' => 'text/plain',
        ],
        [
            "\xC8\xFE\xC6\xFD",
        ]
    ];
    my $res = $app->format_output($response);
    cmp_deeply $res, {
        isBase64Encoded => bool 1,
        headers => {
            'content-type' => 'text/plain',
        },
        multiValueHeaders => {
            'content-type' => ['text/plain'],
        },
        statusCode => 200,
        body => "yP7G/Q==",
    };
    diag encode_json $res;
};

subtest "query string enconding" => sub {
    my $input = decode_json(slurp("$FindBin::Bin/testdata/apigateway-get-request.json"));
    $input->{queryStringParameters} = {
        "gif+ref+" => "",
    };
    $input->{multiValueQueryStringParameters} = {
        "gif+ref+" => [""],
    };
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'GET', 'method';
    is $req->content, '', 'content';
    is $req->request_uri, '/foo%20/bar?gif+ref+=', 'request uri';
    is $req->path_info, '/foo /bar', 'path info';
    is $req->query_string, 'gif+ref+=', 'query string';
};

# inject the request id that compatible with Plack::Middleware::RequestId
subtest "request id" => sub {
    my $context = AWS::Lambda::Context->new(
        deadline_ms    => 1000,
        aws_request_id => '8476a536-e9f4-11e8-9739-2dfe598c3fcd',
        invoked_function_arn => 'arn:aws:lambda:us-east-2:123456789012:function:custom-runtime',
    );
    my $input = decode_json(slurp("$FindBin::Bin/testdata/apigateway-get-request.json"));
    my $output = $app->format_input($input, $context);
    my $req = Plack::Request->new($output);
    is $req->env->{'psgix.request_id'}, '8476a536-e9f4-11e8-9739-2dfe598c3fcd', 'get request id from the env';
    is $req->header('X-Request-Id'), '8476a536-e9f4-11e8-9739-2dfe598c3fcd', 'get request id from the header';
};

done_testing;
