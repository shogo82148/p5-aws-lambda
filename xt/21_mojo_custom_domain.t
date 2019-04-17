use strict;
use warnings;
use utf8;

use Test::More;
use JSON::XS qw/decode_json/;

use AWS::Lambda::PSGI;
use Mojo::Server::PSGI;

my $get_request_for_get_link = <<EOF;
{
    "resource": "/{proxy+}",
    "path": "/get-link",
    "httpMethod": "GET",
    "headers": {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7",
        "CloudFront-Forwarded-Proto": "https",
        "CloudFront-Is-Desktop-Viewer": "true",
        "CloudFront-Is-Mobile-Viewer": "false",
        "CloudFront-Is-SmartTV-Viewer": "false",
        "CloudFront-Is-Tablet-Viewer": "false",
        "CloudFront-Viewer-Country": "JP",
        "Host": "xxxxxx.example.com",
        "upgrade-insecure-requests": "1",
        "User-Agent": "curl/7.54.0",
        "Via": "2.0 xxxxxxxxxxxx.cloudfront.net (CloudFront)",
        "X-Amz-Cf-Id": "A3DaibJs0GRv3WgyO-5jEtkSlUOG-BfqY1sQJwjFt5RoqHw0uPjo8w==",
        "X-Amzn-Trace-Id": "Root=1-5cb40559-7f2aab91110daa905c11c3c9",
        "X-Forwarded-For": "192.0.2.1, 192.0.2.2",
        "X-Forwarded-Port": "443",
        "X-Forwarded-Proto": "https"
    },
    "multiValueHeaders": {
        "Accept": [
            "*/*"
        ],
        "Accept-Encoding": [
            "gzip, deflate, br"
        ],
        "Accept-Language": [
            "ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7"
        ],
        "CloudFront-Forwarded-Proto": [
            "https"
        ],
        "CloudFront-Is-Desktop-Viewer": [
            "true"
        ],
        "CloudFront-Is-Mobile-Viewer": [
            "false"
        ],
        "CloudFront-Is-SmartTV-Viewer": [
            "false"
        ],
        "CloudFront-Is-Tablet-Viewer": [
            "false"
        ],
        "CloudFront-Viewer-Country": [
            "JP"
        ],
        "Host": [
            "xxxxxx.example.com"
        ],
        "upgrade-insecure-requests": [
            "1"
        ],
        "User-Agent": [
            "curl/7.54.0"
        ],
        "Via": [
            "2.0 xxxxxxxxxxxx.cloudfront.net (CloudFront)"
        ],
        "X-Amz-Cf-Id": [
            "A3DaibJs0GRv3WgyO-5jEtkSlUOG-BfqY1sQJwjFt5RoqHw0uPjo8w=="
        ],
        "X-Amzn-Trace-Id": [
            "Root=1-5cb40559-7f2aab91110daa905c11c3c9"
        ],
        "X-Forwarded-For": [
            "192.0.2.1, 192.0.2.2"
        ],
        "X-Forwarded-Port": [
            "443"
        ],
        "X-Forwarded-Proto": [
            "https"
        ]
    },
    "queryStringParameters": null,
    "multiValueQueryStringParameters": null,
    "pathParameters": {
        "proxy": "get-link"
    },
    "stageVariables": null,
    "requestContext": {
        "resourceId": "eto9na",
        "resourcePath": "/{proxy+}",
        "httpMethod": "GET",
        "extendedRequestId": "YKXGBHSvNjMFQmA=",
        "requestTime": "15/Apr/2019:04:15:21 +0000",
        "path": "/get-link",
        "accountId": "445285296882",
        "protocol": "HTTP/1.1",
        "stage": "prod",
        "domainPrefix": "xxxxxx",
        "requestTimeEpoch": 1555301721775,
        "requestId": "15f453fc-5f35-11e9-b133-69be6282d969",
        "identity": {
            "cognitoIdentityPoolId": null,
            "accountId": null,
            "cognitoIdentityId": null,
            "caller": null,
            "sourceIp": "122.249.124.94",
            "accessKey": null,
            "cognitoAuthenticationType": null,
            "cognitoAuthenticationProvider": null,
            "userArn": null,
            "userAgent": "curl/7.54.0",
            "user": null
        },
        "domainName": "xxxxxx.example.com",
        "apiId": "eigh7mjsag"
    },
    "body": null,
    "isBase64Encoded": false
}
EOF

my $server = Mojo::Server::PSGI->new;
$server->load_app('xt/21_mojoapp.pl');
my $func = AWS::Lambda::PSGI->wrap($server->to_psgi_app);
my $input = decode_json($get_request_for_get_link);
my $ret = $func->($input);

cmp_ok($ret->{ body }, 'eq', '/controller1');

done_testing;
