use strict;
use warnings;
use utf8;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";
use BootstrapMock;
use AWS::Lambda::Context;
use Try::Tiny;

my $error;
my $bootstrap = BootstrapMock->new(
    handler     => "echo.handle_not_found",
    runtime_api => "example.com",
    task_root   => "$FindBin::Bin/test_handlers",
    lambda_init_error => sub {
        my $self = shift;
        $error = shift;
    },
);

try {
    $bootstrap->handle_event;
};
like $error, qr/handler handle_not_found is not found/;

done_testing;
