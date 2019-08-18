use utf8;
use strict;
use warnings;
use AWS::Lambda;

# an example of echo
# it is called from 01_echo.t
sub handle {
    my ($payload, $context) = @_;
    die "payload is empty" unless $payload;
    die "context is empty" unless $context;
    die "AWS::Lambda::context is invalid" if $AWS::Lambda::context != $context;
    die "trace_id is empty" unless $ENV{_X_AMZN_TRACE_ID};
    return $payload;
}

1;
