use strict;
use warnings;
use utf8;

use Test::More;
use FindBin;
use JSON::XS qw/decode_json encode_json/;
use File::Slurp qw(slurp);
use Plack::Request;

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

done_testing;
