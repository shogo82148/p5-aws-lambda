#!/usr/bin/env perl

use 5.03800;
use strict;
use warnings;
use FindBin;
use Parallel::ForkManager;
use File::Basename 'basename';
use JSON qw(decode_json encode_json);

my $force = ($ARGV[0] // '') eq '-f';

sub head_or_put {
    my ($key, $zip) = @_;
    my $object = decode_json(`aws --output json --region us-east-1 s3api head-object --bucket shogo82148-lambda-perl-runtime-us-east-1 --key "$key" || echo "{}"`);
    my $current = $object->{Metadata}{md5chksum} || "";
    if (!$current) {
        say STDERR "Upload $zip to 3://shogo82148-lambda-perl-runtime-us-east-1/$key";
        my $cmd = "aws --output json --region 'us-east-1' s3api put-object --bucket 'shogo82148-lambda-perl-runtime-us-east-1' --key '$key' --body '$zip'";
        say STDERR "Executing: $cmd";
        if ($force) {
            $object = decode_json(`$cmd`);
            die "exit: $!" if $! != 0;
        }
    } else {
        say STDERR "s3://shogo82148-lambda-perl-runtime-us-east-1/$key is already updated";
    }
    return $object;
}

sub run_command {
    my @cmd = @_;
    say STDERR "Executing: @cmd";
    if ($force) {
        my $code = system(@cmd);
        die "exit: $code" if $! != 0;
    }
}

sub publish {
    my ($suffix, $arch, $arch_suffix) = @_;
    $arch_suffix //= "-$arch";

    for my $zip(glob "$FindBin::Bin/../.perl-layer/dist/perl-*-$suffix-$arch.zip") {
        chomp(my $sha256 = `openssl dgst -sha256 -r "$zip" | cut -d" " -f1`);
        my $name = basename($zip, '.zip');
        next unless $name =~ /^perl-([0-9]+)-([0-9]+)-/;
        my $perl_version = "$1.$2";

        head_or_put("$name/$sha256.zip", $zip);
        my $metadata = encode_json({
            url => "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/$name/$sha256.zip",
        });
        run_command("echo '$metadata' | aws --region 'us-east-1' s3 cp --content-type application/json - s3://shogo82148-lambda-perl-runtime-us-east-1/$name.json");
    }
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

publish("runtime-al2023", "x86_64");
publish("paws-al2023", "x86_64");
publish("runtime-al2023", "arm64");
publish("paws-al2023", "arm64");

1;
