use utf8;
use strict;
use warnings;
use AWS::Lambda;

sub handle {
    my ($payload, $context) = @_;
    die "payload is empty" unless $payload;
    die "context is empty" unless $context;
    die "AWS::Lambda::context is invalid" if $AWS::Lambda::context != $context;
    return $payload;
}

1;
