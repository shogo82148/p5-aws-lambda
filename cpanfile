requires 'perl', '5.026000';
requires 'HTTP::Tiny', '0.076';
requires 'JSON::XS', '4.0';
requires 'Try::Tiny', '0.30';
requires 'Plack', '1.0047';
requires 'Plack::Middleware::ReverseProxy', '0.16';
requires 'JSON::Types', '0.05';
requires 'URI::Escape';

recommends 'AWS::XRay', '>=0.09';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Deep', '1.128';
    requires 'Test::TCP', '2.19';
    requires 'Test::SharedFork';
    requires 'File::Slurp', '9999.25';
};

on 'develop' => sub {
    requires 'Minilla';
    requires 'Version::Next';
    requires 'Software::License::MIT';
    requires 'Test::CPAN::Meta';
    requires 'Test::Pod';
    requires 'Test::MinimumVersion::Fast';
    requires 'Mojolicious';
    requires 'Dancer2';
};
