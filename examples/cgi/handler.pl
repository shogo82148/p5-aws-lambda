use utf8;
use warnings;
use strict;
use lib "$ENV{'LAMBDA_TASK_ROOT'}/extlocal/lib/perl5";
use AWS::Lambda::PSGI;

$ENV{WWWCOUNT_DIR} = "/tmp";
chdir($ENV{'LAMBDA_TASK_ROOT'});
my $app = require "$ENV{'LAMBDA_TASK_ROOT'}/app.psgi";
my $func = AWS::Lambda::PSGI->wrap($app);

sub handle {
    my $payload = shift;
    return $func->($payload);
}

1;
