#!/usr/bin/env perl

use 5.03000;
use strict;
use warnings;
use FindBin;
use Parallel::ForkManager;
use File::Basename 'basename';
use JSON qw(decode_json);

my $force = ($ARGV[0] // '') eq '-f';

sub head_or_put {
    my ($region, $key, $zip, $md5) = @_;
    my $object = decode_json(`aws --output json --region "$region" s3api head-object --bucket "shogo82148-lambda-perl-runtime-$region" --key "$key" || echo "{}"`);
    my $current = $object->{Metadata}{md5chksum} || "";
    if ($current ne $md5) {
        say STDERR "Upload $zip to 3://shogo82148-lambda-perl-runtime-$region/$key";
        my $cmd = "aws --output json --region '$region' s3api put-object --bucket 'shogo82148-lambda-perl-runtime-$region' --acl public-read --key '$key' --body '$zip' --content-md5 '$md5' --metadata md5chksum='$md5'";
        say STDERR "Excuting: $cmd";
        if ($force) {
            $object = decode_json(`$cmd`);
            die "exit: $!" if $! != 0;
        }
    } else {
        say STDERR "$zip in s3://shogo82148-lambda-perl-runtime-$region/$key is already updated";
    }
    return $object;
}

sub run_command {
    my @cmd = @_;
    say STDERR "Excuting: @cmd";
    if ($force) {
        my $code = system(@cmd);
        die "exit: $code" if $! != 0;
    }
}

sub publish {
    my ($suffix, $arch, $arch_suffix) = @_;
    $arch_suffix //= "-$arch";
    my $pm = Parallel::ForkManager->new(10);

    my $regions = do {
        open my $fh, '<', "$FindBin::Bin/regions-$arch.txt" or die "$!";
        my @regions = sort { $a cmp $b } map { chomp; $_; } <$fh>;
        close($fh);
        \@regions;
    };

    for my $zip(glob "$FindBin::Bin/../.perl-layer/dist/perl-*-$suffix-$arch.zip") {
        chomp(my $md5 = `openssl dgst -md5 -binary "$zip" | openssl enc -base64`);
        my $name = basename($zip, '.zip');
        next unless $name =~ /^perl-([0-9]+)-([0-9]+)-/;
        my $perl_version = "$1.$2";
        my $stack = $perl_version =~ s/[.]/-/r;
        for my $region(@$regions) {
            $pm->start("$region/$perl_version") and next;
            say STDERR "$region/$perl_version: START";
            my $object = head_or_put($region, "perl-$stack-$suffix$arch_suffix.zip", $zip, $md5);
            my $version = $object->{VersionId} // 'UNKNOWN';
            my $stack_name = "lambda-$stack-$suffix$arch_suffix" =~ s/_/-/r;

            say STDERR "deploying stack $stack_name in $region...";
            run_command('aws', '--region', $region, 'cloudformation', 'deploy',
                '--stack-name', $stack_name,
                '--template-file', "$FindBin::Bin/cfn-layer-$suffix-$arch.yml",
                '--parameter-overrides', "PerlVersion=$perl_version", "Name=perl-$stack-$suffix$arch_suffix", "ObjectVersion=$version");
            say STDERR "$region/$perl_version: DONE";
            $pm->finish(0);
        }
    }

    $pm->wait_all_children;
}

if ($force) {
    say STDERR "FORCE TO DEPLOY";
} else {
    say STDERR "DRY RUN";
}

publish("runtime-al2", "x86_64");
publish("paws-al2", "x86_64");
publish("runtime-al2", "arm64");
publish("paws-al2", "arm64");

1;
