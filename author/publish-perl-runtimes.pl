#!/usr/bin/env perl

use 5.03000;
use strict;
use warnings;
use FindBin;
use Parallel::ForkManager;
use File::Basename 'basename';
use JSON qw(decode_json);

my $regions = do {
    open my $fh, '<', "$FindBin::Bin/regions-x86_64.txt" or die "$!";
    my @regions = sort { $a cmp $b } map { chomp; $_; } <$fh>;
    close($fh);
    \@regions;
};

sub publish {
    my ($suffix) = @_;
    my $pm = Parallel::ForkManager->new(10);

    for my $zip(glob "$FindBin::Bin/../.perl-layer/dist/perl-*-$suffix-x86_64.zip") {
        chomp(my $md5 = `openssl dgst -md5 -binary "$zip" | openssl enc -base64`);
        my $name = basename($zip, '.zip');
        next unless $name =~ /^perl-([0-9]+)-([0-9]+)/;
        my $perl_version = "$1.$2";
        my $stack = $perl_version =~ s/[.]/-/r;
        for my $region(@$regions) {
            $pm->start("$region/$perl_version") and next;
            say STDERR "$region/$perl_version: START";
            my $object = decode_json(`aws --output json --region "$region" s3api head-object --bucket "shogo82148-lambda-perl-runtime-$region" --key "$name.zip" || echo "{}"`);
            my $current = $object->{Metadata}{md5chksum} || "";
            if ($current ne $md5) {
                say STDERR "Uploading $name.zip to shogo82148-lambda-perl-runtime-$region";
                $object = decode_json(`aws --output json --region "$region" s3api put-object --bucket "shogo82148-lambda-perl-runtime-$region" --acl public-read --key "$name.zip" --body "$zip" --content-md5 "$md5" --metadata md5chksum="$md5"`);
            } else {
                say STDERR "$name.zip in shogo82148-lambda-perl-runtime-$region is already updated";
            }
            say STDERR "deploying stack lambda-$stack-$suffix in $region...";
            my $version = $object->{VersionId};
            system('aws', '--region', $region, 'cloudformation', 'deploy',
                '--stack-name', "lambda-$stack-$suffix",
                '--template-file', "$FindBin::Bin/cfn-layer-$suffix.yml",
                '--parameter-overrides', "PerlVersion=$perl_version", "Name=$name", "ObjectVersion=$version");
            say STDERR "$region/$perl_version: DONE";
            $pm->finish(0);
        }
    }

    $pm->wait_all_children;
}

publish("runtime");
publish("paws");
publish("runtime-al2");
publish("paws-al2");

1;
