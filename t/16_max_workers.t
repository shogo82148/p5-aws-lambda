use strict;
use warnings;
use utf8;

use Test::More;
use Test::TCP;
use HTTP::Server::PSGI;
use FindBin;
use AWS::Lambda::Bootstrap;
use Test::Deep;

my $bootstrap = AWS::Lambda::Bootstrap->new(
    handler     => "echo.handle",
    task_root   => "$FindBin::Bin/test_handlers",
    runtime_api => "example.com",
    max_workers => 5,
);

my $manager_pid = $$;
{
    no warnings 'redefine';
    *AWS::Lambda::Bootstrap::_handle_events = sub {
        sleep 1;
        kill 'TERM', $manager_pid;
    };
}

$bootstrap->handle_events;

pass("Bootstrap with max_workers ran without errors");

done_testing;
