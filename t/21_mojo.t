use strict;
use warnings;
use utf8;

use Test::More;
use FindBin;
use JSON::XS qw/decode_json encode_json/;
use File::Slurp qw(slurp);
use Plack::Request;
use Test::Deep qw(cmp_deeply);
use JSON::Types;
use Encode;

use AWS::Lambda::PSGI;
use Mojo::Server::PSGI;

my $app = AWS::Lambda::PSGI->new;

my $get_request_for_get_link = <<EOF;
{
    "resource": "/{proxy+}",
    "path": "/get-link",
    "httpMethod": "GET",
    "headers": {
        "X-Forwarded-For": "192.0.2.1",
        "X-Forwarded-Port": "443",
        "X-Forwarded-Proto": "https"
    },
    "multiValueHeaders": {
    },
    "queryStringParameters": {
    },
    "multiValueQueryStringParameters": {
    },
    "pathParameters": {
        "proxy": "get-link"
    },
    "stageVariables": null,
    "requestContext": {
        "resourceId": "eto9na",
        "resourcePath": "/{proxy+}",
        "httpMethod": "GET",
        "extendedRequestId": "RuNw7G65tjMFreQ=",
        "requestTime": "11/Dec/2018:03:06:07 +0000",
        "path": "/prod/get-link",
        "accountId": "123456789012",
        "protocol": "HTTP/1.1",
        "stage": "prod",
        "domainPrefix": "xxxxxxxxxx",
        "requestTimeEpoch": 1544497567503,
        "requestId": "b42dfa11-fcf1-11e8-b9d0-b9272ebf40e8",
        "identity": {
            "cognitoIdentityPoolId": null,
            "accountId": null,
            "cognitoIdentityId": null,
            "caller": null,
            "sourceIp": "192.0.2.1",
            "accessKey": null,
            "cognitoAuthenticationType": null,
            "cognitoAuthenticationProvider": null,
            "userArn": null,
            "userAgent": "curl/7.54.0",
            "user": null
        },
        "domainName": "xxxxxxxxxx.execute-api.ap-northeast-1.amazonaws.com",
        "apiId": "xxxxxxxxxx"
    },
    "body": null,
    "isBase64Encoded": false
}
EOF

my $server = Mojo::Server::PSGI->new;
$server->load_app('t/21_mojoapp');
my $func = AWS::Lambda::PSGI->wrap($server->to_psgi_app);
my $input = decode_json($get_request_for_get_link);
my $ret = $func->($input);

cmp_ok($ret->{ body }, 'eq', '/prod/controller1');

done_testing;
