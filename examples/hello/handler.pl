use utf8;
use warnings;
use strict;

sub handle {
    my $payload = shift;
    return +{"hello" => "lambda"};
}

1;
