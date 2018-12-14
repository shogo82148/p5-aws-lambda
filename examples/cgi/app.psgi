use Plack::App::WrapCGI;
my $app = Plack::App::WrapCGI->new(script => "./wwwcount.cgi")->to_app;
