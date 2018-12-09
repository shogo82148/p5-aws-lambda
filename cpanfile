requires 'perl', '5.026000';
requires 'HTTP::Tiny', '0.076';
requires 'JSON::XS', '4.0';
requires 'Try::Tiny', '0.30';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Deep', '1.128';
    requires 'Test::TCP', '2.19';
    requires 'HTTP::Server::PSGI';
    requires 'Test::SharedFork';
};
