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

sub slurp_json {
    my $name = $_[0];
    return decode_json(slurp("$FindBin::Bin/$name"));
}

sub slurp_fh {
    my $fh = shift;
    my $data = "";
    while ($fh->read(my $buf, 4096)) {
        $data .= $buf;
    }
    return decode_utf8($data);
}

my $app = AWS::Lambda::PSGI->new;

subtest "API Gateway GET Request" => sub {
    my $input = slurp_json("testdata/apigateway-get-request.json");
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
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "API Gateway POST Request" => sub {
    my $input = slurp_json("testdata/apigateway-post-request.json");
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    is $req->content_type, 'application/json', 'content-type';
    my $content;
    warning_is { $content = slurp_fh($req->input) } undef, 'no warning';
    is $content, '{"hello":"こんにちは世界"}', 'content';
    is $req->request_uri, '/', 'request uri';
    is $req->path_info, '/', 'path info';
    is $req->query_string, '', 'query string';
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "API Gateway Base64 encoded POST Request" => sub {
    my $input = slurp_json("testdata/apigateway-base64-request.json");
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
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "API Gateway v2 GET Request" => sub {
    my $input = slurp_json("testdata/apigateway-v2-get-request.json");
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
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "API Gateway v2 POST Request" => sub {
    my $input = slurp_json("testdata/apigateway-v2-post-request.json");
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    my $content;
    warning_is { $content = slurp_fh($req->input) } undef, 'no warning';
    is $content, '{"hello":"こんにちは世界"}', 'content';
    is $req->request_uri, '/my/path', 'request uri';
    is $req->path_info, '/my/path', 'path info';
    is $req->query_string, '', 'query string';
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "API Gateway v2 base64 Request" => sub {
    my $input = slurp_json("testdata/apigateway-v2-base64-request.json");
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    my $content;
    warning_is { $content = slurp_fh($req->input) } undef, 'no warning';
    is $content, '{"hello":"world"}', 'content';
    is $req->request_uri, '/my/path', 'request uri';
    is $req->path_info, '/my/path', 'path info';
    is $req->query_string, '', 'query string';
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "ALB GET Request" => sub {
    my $input = slurp_json("testdata/alb-get-request.json");
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'GET', 'method';
    is slurp_fh($req->input), '', 'content';
    is $req->request_uri, '/foo/bar?query=hoge&query=fuga', 'request uri';
    is $req->path_info, '/foo/bar', 'path info';
    is $req->query_string, 'query=hoge&query=fuga', 'query string';
    is $req->header('Header-Name'), 'Value1, Value2', 'header';
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "ALB POST Request" => sub {
    my $input = slurp_json("testdata/alb-post-request.json");
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    is $req->content_type, 'application/json', 'content-type';
    is slurp_fh($req->input), '{"hello":"こんにちは世界"}', 'content';
    is $req->request_uri, '/', 'request uri';
    is $req->path_info, '/', 'path info';
    is $req->query_string, '', 'query string';
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "ALB POST Base64 Request" => sub {
    my $input = slurp_json("testdata/alb-base64-request.json");
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    is $req->content_type, 'application/octet-stream', 'content-type';
    is slurp_fh($req->input), '{"hello":"world"}', 'content';
    is $req->request_uri, '/foo/bar', 'request uri';
    is $req->path_info, '/foo/bar', 'path info';
    is $req->query_string, '', 'query string';
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "Function URLs GET Request" => sub {
    my $input = slurp_json("testdata/function-urls-get-request.json");
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'GET', 'method';
    is slurp_fh($req->input), '', 'content';
    is $req->request_uri, '/foo /bar?parameter1=value1&parameter1=value2&parameter2=value', 'request uri';
    is $req->path_info, '/foo /bar', 'path info';
    is $req->query_string, 'parameter1=value1&parameter1=value2&parameter2=value', 'query string';
    is $req->header('header1'), 'value1,value2', 'header';
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "Function URLs POST Request" => sub {
    my $input = slurp_json("testdata/function-urls-post-request.json");
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    is $req->content_type, 'application/json', 'content-type';
    is slurp_fh($req->input), '{"hello":"world"}', 'content';
    is $req->request_uri, '/my/path', 'request uri';
    is $req->path_info, '/my/path', 'path info';
    is $req->query_string, '', 'query string';
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
};

subtest "Function URLs POST Base64 Request" => sub {
    my $input = slurp_json("testdata/function-urls-post-base64-request.json");
    my $output = $app->format_input($input);
    my $req = Plack::Request->new($output);
    is $req->method, 'POST', 'method';
    is $req->content_type, 'application/octet-stream', 'content-type';
    is slurp_fh($req->input), '{"hello":"world"}', 'content';
    is $req->request_uri, '/my/path', 'request uri';
    is $req->path_info, '/my/path', 'path info';
    is $req->query_string, '', 'query string';
    ok !$req->env->{'psgi.streaming'}, 'psgi.streaming';
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
    my $input = slurp_json("testdata/apigateway-get-request.json");
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
    my $input = slurp_json("testdata/apigateway-get-request.json");
    my $output = $app->format_input($input, $context);
    my $req = Plack::Request->new($output);
    is $req->env->{'psgix.request_id'}, '8476a536-e9f4-11e8-9739-2dfe598c3fcd', 'get request id from the env';
    is $req->header('X-Request-Id'), '8476a536-e9f4-11e8-9739-2dfe598c3fcd', 'get request id from the header';
};


subtest "remote address, scheme and port from the event" => sub {
    my @cases = (
        ["apigateway-get-request.json",          '192.0.2.1',      'https', 443],
        ["apigateway-post-request.json",         undef,            'https', 443],
        ["apigateway-v2-get-request.json",       '192.0.2.1',      'https', 443],
        ["function-urls-get-request.json",       '192.0.2.1',      'https', 443],
        ["alb-get-request.json",                 '122.249.124.94', 'https', 443],
    );
    for my $case (@cases) {
        my ($file, $addr, $scheme, $port) = @$case;
        my $input = slurp_json("testdata/$file");
        $addr //= $input->{requestContext}{identity}{sourceIp};
        my $env = $app->format_input($input);
        is $env->{REMOTE_ADDR}, $addr, "$file: REMOTE_ADDR";
        is $env->{'psgi.url_scheme'}, $scheme, "$file: psgi.url_scheme";
        is $env->{SERVER_PORT}, $port, "$file: SERVER_PORT";
    }

    # ALB on a plain HTTP listener
    my $input = slurp_json("testdata/alb-get-request.json");
    $input->{multiValueHeaders}{'x-forwarded-proto'} = ['http'];
    $input->{multiValueHeaders}{'x-forwarded-port'} = ['80'];
    my $env = $app->format_input($input);
    is $env->{'psgi.url_scheme'}, 'http', 'ALB http: psgi.url_scheme';
    is $env->{SERVER_PORT}, 80, 'ALB http: SERVER_PORT';
};

# A client can send headers like "X_Forwarded_For" and "X-Forwarded-For".
# They must not change REMOTE_ADDR.
subtest "wrap takes REMOTE_ADDR from the event, not from forged X-Forwarded-For" => sub {
    my $env;
    my $func = AWS::Lambda::PSGI->wrap(sub {
        $env = { %{$_[0]} };
        return [200, ['Content-Type' => 'text/plain'], ['ok']];
    }, invoke_mode => 'BUFFERED');

    # API Gateway REST API
    my $input = slurp_json("testdata/apigateway-get-request.json");
    $input->{headers}{'X-Forwarded-For'} = '203.0.113.1';
    $input->{multiValueHeaders}{'X-Forwarded-For'} = ['203.0.113.1'];
    $input->{headers}{'x_forwarded_for'} = '203.0.113.2';
    $input->{multiValueHeaders}{'x_forwarded_for'} = ['203.0.113.2'];
    my $res = $func->($input);
    is $res->{statusCode}, 200, 'REST: status code';
    is $env->{REMOTE_ADDR}, '192.0.2.1', 'REST: REMOTE_ADDR is sourceIp';
    is $env->{HTTP_X_FORWARDED_FOR}, '203.0.113.1', 'REST: the app sees X-Forwarded-For, not X_Forwarded_For';
    is $env->{'psgi.url_scheme'}, 'https', 'REST: psgi.url_scheme';
    is $env->{SERVER_PORT}, 443, 'REST: SERVER_PORT';

    # Lambda Function URLs
    $input = slurp_json("testdata/function-urls-get-request.json");
    $input->{headers}{'x-forwarded-for'} = '203.0.113.1';
    $input->{headers}{'x_forwarded_for'} = '203.0.113.2';
    $res = $func->($input);
    is $res->{statusCode}, 200, 'Function URLs: status code';
    is $env->{REMOTE_ADDR}, '192.0.2.1', 'Function URLs: REMOTE_ADDR is sourceIp';
    is $env->{HTTP_X_FORWARDED_FOR}, '203.0.113.1', 'Function URLs: the app sees X-Forwarded-For, not X_Forwarded_For';

    # API Gateway HTTP API without X-Forwarded-For
    $input = slurp_json("testdata/apigateway-v2-get-request.json");
    delete $input->{headers}{'x-forwarded-for'};
    $res = $func->($input);
    is $res->{statusCode}, 200, 'HTTP API: status code';
    is $env->{REMOTE_ADDR}, '192.0.2.1', 'HTTP API: REMOTE_ADDR is sourceIp';
    ok !exists $env->{HTTP_X_FORWARDED_FOR}, 'HTTP API: no X-Forwarded-For';

    # ALB appends the client address to X-Forwarded-For.
    $input = slurp_json("testdata/alb-get-request.json");
    $input->{multiValueHeaders}{'x-forwarded-for'} = ['203.0.113.1, 122.249.124.94'];
    $input->{multiValueHeaders}{'x_forwarded_for'} = ['203.0.113.2'];
    $res = $func->($input);
    is $res->{statusCode}, 200, 'ALB: status code';
    is $env->{REMOTE_ADDR}, '122.249.124.94', 'ALB: REMOTE_ADDR is the address that ALB appended';
    is $env->{'psgi.url_scheme'}, 'https', 'ALB: psgi.url_scheme';
    is $env->{SERVER_PORT}, 443, 'ALB: SERVER_PORT';

    # ALB removes X-Forwarded-For (routing.http.xff_header_processing.mode = remove).
    $input = slurp_json("testdata/alb-get-request.json");
    delete $input->{multiValueHeaders}{'x-forwarded-for'};
    $input->{multiValueHeaders}{'x_forwarded_for'} = ['203.0.113.2'];
    $res = $func->($input);
    is $res->{statusCode}, 200, 'ALB without X-Forwarded-For: status code';
    ok !defined $env->{REMOTE_ADDR}, 'ALB without X-Forwarded-For: REMOTE_ADDR is not forged';
    ok !exists $env->{HTTP_X_FORWARDED_FOR}, 'ALB without X-Forwarded-For: X_Forwarded_For is dropped';
};


# A client can send headers like "X_Forwarded_Proto" and "X_Forwarded_Port".
# They must not change the URL scheme or the port.
subtest "wrap takes the scheme and the port from the event, not from forged X-Forwarded-Proto" => sub {
    my $env;
    my $func = AWS::Lambda::PSGI->wrap(sub {
        $env = { %{$_[0]} };
        return [200, ['Content-Type' => 'text/plain'], ['ok']];
    }, invoke_mode => 'BUFFERED');

    # ALB on a plain HTTP listener, with forged headers next to the ones ALB sets.
    my $input = slurp_json("testdata/alb-get-request.json");
    my $host = $input->{multiValueHeaders}{host}[0];
    $input->{multiValueHeaders}{'x-forwarded-proto'} = ['http'];
    $input->{multiValueHeaders}{'x-forwarded-port'} = ['80'];
    $input->{multiValueHeaders}{'x_forwarded_proto'} = ['https'];
    $input->{multiValueHeaders}{'x_forwarded_port'} = ['443'];
    my $res = $func->($input);
    is $res->{statusCode}, 200, 'ALB http: status code';
    is $env->{'psgi.url_scheme'}, 'http', 'ALB http: psgi.url_scheme';
    ok !$env->{HTTPS}, 'ALB http: HTTPS is not set';
    is $env->{SERVER_PORT}, 80, 'ALB http: SERVER_PORT';
    is(Plack::Request->new($env)->base->as_string, "http://$host/", 'ALB http: base url');
    is $env->{HTTP_X_FORWARDED_PROTO}, 'http', 'ALB http: the app sees X-Forwarded-Proto, not X_Forwarded_Proto';
    is $env->{HTTP_X_FORWARDED_PORT}, '80', 'ALB http: the app sees X-Forwarded-Port, not X_Forwarded_Port';

    # only the forged header, without X-Forwarded-Proto
    $input = slurp_json("testdata/alb-get-request.json");
    delete $input->{multiValueHeaders}{'x-forwarded-proto'};
    $input->{multiValueHeaders}{'x-forwarded-port'} = ['80'];
    $input->{multiValueHeaders}{'x_forwarded_proto'} = ['https'];
    $res = $func->($input);
    is $res->{statusCode}, 200, 'ALB http, forged header only: status code';
    is $env->{'psgi.url_scheme'}, 'http', 'ALB http, forged header only: psgi.url_scheme';
    ok !$env->{HTTPS}, 'ALB http, forged header only: HTTPS is not set';
    ok !exists $env->{HTTP_X_FORWARDED_PROTO}, 'ALB http, forged header only: X_Forwarded_Proto is dropped';

    # ALB on an HTTPS listener
    $input = slurp_json("testdata/alb-get-request.json");
    $input->{multiValueHeaders}{'x_forwarded_proto'} = ['http'];
    $res = $func->($input);
    is $res->{statusCode}, 200, 'ALB https: status code';
    is $env->{'psgi.url_scheme'}, 'https', 'ALB https: psgi.url_scheme';
    is $env->{HTTPS}, 'ON', 'ALB https: HTTPS';
    is $env->{SERVER_PORT}, 443, 'ALB https: SERVER_PORT';
    is(Plack::Request->new($env)->base->as_string, "https://$host/", 'ALB https: base url');

    # Lambda Function URLs accept only HTTPS.
    $input = slurp_json("testdata/function-urls-get-request.json");
    $host = $input->{headers}{host};
    $input->{headers}{'x_forwarded_proto'} = 'http';
    $input->{headers}{'x_forwarded_port'} = '80';
    $res = $func->($input);
    is $res->{statusCode}, 200, 'Function URLs: status code';
    is $env->{'psgi.url_scheme'}, 'https', 'Function URLs: psgi.url_scheme';
    is $env->{HTTPS}, 'ON', 'Function URLs: HTTPS';
    is $env->{SERVER_PORT}, 443, 'Function URLs: SERVER_PORT';
    is(Plack::Request->new($env)->base->as_string, "https://$host/", 'Function URLs: base url');
};


# X-Forwarded-Host, X-Forwarded-Server and X-Forwarded-HTTPS are not set by the AWS front ends.
# They come from the client, so wrap must not let them rewrite the host, the port or the scheme.
subtest "wrap ignores client supplied forwarded host headers" => sub {
    my $env;
    my $func = AWS::Lambda::PSGI->wrap(sub {
        $env = { %{$_[0]} };
        return [200, ['Content-Type' => 'text/plain'], ['ok']];
    }, invoke_mode => 'BUFFERED');

    my $input = slurp_json("testdata/function-urls-get-request.json");
    my $host = $input->{headers}{host};
    $input->{headers}{'x-forwarded-host'} = '203.0.113.1:8443';
    $input->{headers}{'x-forwarded-server'} = '203.0.113.2:8443';
    $input->{headers}{'x-forwarded-https'} = 'ON';
    my $res = $func->($input);
    is $res->{statusCode}, 200, 'status code';
    is $env->{HTTP_HOST}, $host, 'host is not rewritten';
    is $env->{SERVER_PORT}, 443, 'port is not rewritten';
    is $env->{'psgi.url_scheme'}, 'https', 'scheme';
    is $env->{HTTP_X_FORWARDED_HOST}, '203.0.113.1:8443', 'the app still sees X-Forwarded-Host';
    is $env->{HTTP_X_FORWARDED_SERVER}, '203.0.113.2:8443', 'the app still sees X-Forwarded-Server';
    is $env->{HTTP_X_FORWARDED_HTTPS}, 'ON', 'the app still sees X-Forwarded-HTTPS';
    is(Plack::Request->new($env)->base->as_string, "https://$host/", 'base url');

    # X-Forwarded-HTTPS does not upgrade a plain HTTP request.
    $input = slurp_json("testdata/alb-get-request.json");
    $host = $input->{multiValueHeaders}{host}[0];
    $input->{multiValueHeaders}{'x-forwarded-proto'} = ['http'];
    $input->{multiValueHeaders}{'x-forwarded-port'} = ['80'];
    $input->{multiValueHeaders}{'x-forwarded-https'} = ['ON'];
    $input->{multiValueHeaders}{'x-forwarded-host'} = ['203.0.113.1'];
    $res = $func->($input);
    is $res->{statusCode}, 200, 'status code';
    is $env->{HTTP_HOST}, $host, 'host is not rewritten';
    ok !$env->{HTTPS}, 'HTTPS is not set';
    is $env->{'psgi.url_scheme'}, 'http', 'scheme is http';
    is $env->{SERVER_PORT}, 80, 'port is not rewritten';
};

# The port comes from X-Forwarded-Port that ALB sets, not from the Host header.
subtest "wrap takes the ALB listener port from X-Forwarded-Port" => sub {
    my $env;
    my $func = AWS::Lambda::PSGI->wrap(sub {
        $env = { %{$_[0]} };
        return [200, ['Content-Type' => 'text/plain'], ['ok']];
    }, invoke_mode => 'BUFFERED');

    my $input = slurp_json("testdata/alb-get-request.json");
    $input->{multiValueHeaders}{'x-forwarded-port'} = ['8443'];
    my $res = $func->($input);
    is $res->{statusCode}, 200, 'status code';
    is $env->{SERVER_PORT}, 8443, 'SERVER_PORT';
    is $env->{'psgi.url_scheme'}, 'https', 'scheme';
};

# "-" becomes "_" in the PSGI env, so a header such as "x_amzn_oidc_identity" could overwrite
# "x-amzn-oidc-identity" that the front end sets. Header names with underscores are dropped.
subtest "headers whose names contain an underscore are dropped" => sub {
    # API Gateway REST API (headers and multiValueHeaders)
    my $input = slurp_json("testdata/apigateway-get-request.json");
    $input->{headers}{'X-Amzn-Oidc-Identity'} = 'alice';
    $input->{multiValueHeaders}{'X-Amzn-Oidc-Identity'} = ['alice'];
    for my $name (qw(x_amzn_oidc_identity X_Amzn-Oidc-Identity X-Amzn_Oidc-Identity)) {
        $input->{headers}{$name} = 'mallory';
        $input->{multiValueHeaders}{$name} = ['mallory'];
    }
    $input->{headers}{'content_type'} = 'text/x-forged';
    $input->{multiValueHeaders}{'content_type'} = ['text/x-forged'];
    $input->{headers}{'X_Custom'} = 'value';
    $input->{multiValueHeaders}{'X_Custom'} = ['value'];
    for (1..20) {
        my $env = $app->format_input($input);
        is $env->{HTTP_X_AMZN_OIDC_IDENTITY}, 'alice', 'REST: the header that the front end sets wins';
    }
    my $env = $app->format_input($input);
    ok !exists $env->{CONTENT_TYPE}, 'REST: content_type is dropped';
    ok !exists $env->{HTTP_X_CUSTOM}, 'REST: X_Custom is dropped';
    is $env->{HTTP_HEADER_NAME}, 'Value1, Value2', 'REST: other headers are kept';

    # ALB (multiValueHeaders only)
    $input = slurp_json("testdata/alb-get-request.json");
    $input->{multiValueHeaders}{'x-amzn-oidc-identity'} = ['alice'];
    $input->{multiValueHeaders}{'x_amzn_oidc_identity'} = ['mallory'];
    for (1..20) {
        $env = $app->format_input($input);
        is $env->{HTTP_X_AMZN_OIDC_IDENTITY}, 'alice', 'ALB: the header that the front end sets wins';
    }

    # ALB that did not authenticate the request: the forged header must not appear at all.
    delete $input->{multiValueHeaders}{'x-amzn-oidc-identity'};
    $env = $app->format_input($input);
    ok !exists $env->{HTTP_X_AMZN_OIDC_IDENTITY}, 'ALB: x_amzn_oidc_identity alone is dropped';

    # API Gateway HTTP API and Lambda Function URLs
    for my $file (qw(apigateway-v2-get-request.json function-urls-get-request.json)) {
        $input = slurp_json("testdata/$file");
        $input->{headers}{'x-amzn-oidc-identity'} = 'alice';
        $input->{headers}{'x_amzn_oidc_identity'} = 'mallory';
        $input->{headers}{'x_custom'} = 'value';
        for (1..20) {
            $env = $app->format_input($input);
            is $env->{HTTP_X_AMZN_OIDC_IDENTITY}, 'alice', "$file: the header that the front end sets wins";
        }
        ok !exists $env->{HTTP_X_CUSTOM}, "$file: x_custom is dropped";
        is $env->{HTTP_HOST}, $input->{headers}{host}, "$file: other headers are kept";
    }
};

done_testing;
