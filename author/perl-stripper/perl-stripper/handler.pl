use v5.36;
use utf8;
use lib "$ENV{'LAMBDA_TASK_ROOT'}/local/lib/perl5";
use lib "$ENV{'LAMBDA_TASK_ROOT'}/local/lib/perl5/aarch64-linux";

use Perl::Strip;
use AWS::Lambda::PSGI;

my $app = sub {
    return [
        200,
        ['Content-Type' => 'text/plain'],
        ["Hello, Lambda!\n"],
    ];
};

my $func = AWS::Lambda::PSGI->wrap($app);

sub handle($payload, $context) {
    return $func->($payload);
}

1;
