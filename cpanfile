requires 'perl', '5.026000';
requires 'HTTP::Tiny', '0.076';
requires 'JSON::XS', '4.0';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Deep', '1.128'
};
