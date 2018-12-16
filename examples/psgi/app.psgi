use strict;
use warnings;
use utf8;
use Plack::Request;
use Plack::Builder;
use Data::Dumper;

return builder {
    mount '/foo' => sub {
        my $env = shift;
        my $req = Plack::Request->new($env);

        my $meth = $req->method;
        if ($meth eq 'POST') {
            return [
                200,
                ['Content-Type', 'application/octet-stream'],
                [$req->content],
            ]
        }

        return [
            405,
            ['Content-Type', 'text/plain'],
            ['Method Not Allowed'],
        ]
    };
    mount '/' => sub {
        my $env = shift;
        return [
            200,
            ['Content-Type', 'text/plain'],
            [Dumper($env)],
        ]
    };
};
