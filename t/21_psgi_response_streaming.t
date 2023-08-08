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
    my $fh = $_[0];
    local $/;
    my $v = <$fh>;
    defined $v ? decode_utf8($v) : '';
}

my $app = AWS::Lambda::PSGI->new;

subtest "array reference" => sub {
    my $content_type = undef;
    my $buf = "";
    my $res = $app->_handle_response_stream([200, ["Content-Type" => "text/plain"], ["hello"]]);
    my $responder = sub {
        $content_type = shift;
        open my $fh, ">", \$buf or die "failed to open: $!";
        return $fh;
    };

    $res->($responder);
    is $content_type, "application/vnd.awslambda.http-integration-response", "content type";
    my ($prelude, $body) = split /\x00\x00\x00\x00\x00\x00\x00\x00/, $buf;
    cmp_deeply decode_json($prelude), {
        statusCode => 200,
        headers => {
            "content-type" => "text/plain",
        },
        cookies => [],
    }, "prelude";
    is $body, "hello", "body";
};

subtest "IO::Handle-like object" => sub {
    my $content_type = undef;
    open my $fh, "<", \"hello" or die "failed to open: $!";
    my $buf = "";
    my $res = $app->_handle_response_stream([200, ["Content-Type" => "text/plain"], $fh]);
    my $responder = sub {
        $content_type = shift;
        open my $fh, ">", \$buf or die "failed to open: $!";
        return $fh;
    };

    $res->($responder);
    is $content_type, "application/vnd.awslambda.http-integration-response", "content type";
    my ($prelude, $body) = split /\x00\x00\x00\x00\x00\x00\x00\x00/, $buf;
    cmp_deeply decode_json($prelude), {
        statusCode => 200,
        headers => {
            "content-type" => "text/plain",
        },
        cookies => [],
    }, "prelude";
    is $body, "hello", "body";
};

subtest "streaming response" => sub {
    my $content_type = undef;
    my $buf = "";
    my $res = $app->_handle_response_stream(sub {
        my $responder = shift;
        my $writer = $responder->([200, ["Content-Type" => "text/plain"]]);
        $writer->write("hello");
        $writer->close;
    });
    my $responder = sub {
        $content_type = shift;
        open my $fh, ">", \$buf or die "failed to open: $!";
        return $fh;
    };

    $res->($responder);
    is $content_type, "application/vnd.awslambda.http-integration-response", "content type";
    my ($prelude, $body) = split /\x00\x00\x00\x00\x00\x00\x00\x00/, $buf;
    cmp_deeply decode_json($prelude), {
        statusCode => 200,
        headers => {
            "content-type" => "text/plain",
        },
        cookies => [],
    }, "prelude";
    is $body, "hello", "body";
};

done_testing;
