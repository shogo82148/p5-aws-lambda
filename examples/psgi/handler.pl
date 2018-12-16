use utf8;
use warnings;
use strict;
use AWS::Lambda::PSGI;

my $app = require "$ENV{'LAMBDA_TASK_ROOT'}/app.psgi";
my $func = AWS::Lambda::PSGI->wrap($app);

sub handle {
    my $payload = shift;
    return $func->($payload);
}

1;
