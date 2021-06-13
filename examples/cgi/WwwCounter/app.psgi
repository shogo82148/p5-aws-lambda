use utf8;
use strict;
use warnings;
use Plack::Builder;
use Plack::App::File;
use Plack::App::WrapCGI;

my $count_dir = $ENV{WWWCOUNT_DIR} // ".";
for my $ext("cnt", "acc", "dat") {
    open my $fh, ">>", "$count_dir/wwwcount.$ext" or die "cannot touch wwwcount.$ext";
    close $fh;
}
mkdir "$count_dir/lock", 0777;

return builder {
    mount '/wwwcount.cgi' => Plack::App::WrapCGI->new(
        script => "./wwwcount.cgi",
        execute => 1,
    )->to_app;
    mount '/' => Plack::App::File->new(
        file => "./sample.html",
        encoding => "utf-8",
    )->to_app;
};
