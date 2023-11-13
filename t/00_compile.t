use strict;
use Test::More 0.98;

use_ok $_ for qw(
    AWS::Lambda
    AWS::Lambda::AL
    AWS::Lambda::AL2
    AWS::Lambda::AL2023
    AWS::Lambda::Bootstrap
    AWS::Lambda::Context
    AWS::Lambda::PSGI
);

done_testing;

