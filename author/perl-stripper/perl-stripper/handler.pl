use v5.36;
use utf8;
use local::lib "$ENV{'LAMBDA_TASK_ROOT'}/local";

use Perl::Strip;
use Plack::Request;
use AWS::Lambda::PSGI;

mkdir '/tmp/.perl-strip';
my $stripper = Perl::Strip->new(
    cache => '/tmp/.perl-strip',
    optimise_size => 1,
);

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    my $code = do { local $/; my $body = $req->body; <$body> };
    my $stripped = $stripper->strip($code);

    my $res = $req->new_response(200);
    $res->content_type('text/plain');
    $res->body($stripped);
    return $res->finalize;
};

my $func = AWS::Lambda::PSGI->wrap($app);

sub handle($payload, $context) {
    return $func->($payload);
}

1;
