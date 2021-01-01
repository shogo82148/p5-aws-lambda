#!/usr/bin/env perl

use 5.032;
use strict;
use warnings;
use utf8;
use IPC::Open3;
use FindBin;
use Carp qw/croak/;
use JSON qw/decode_json/;
use File::Path qw/mkpath/;

my $current_state = {};
my $state = {};

my $perl_versions = [qw/5.26 5.28 5.30 5.32/];
my $perl_versions_al2 = [qw/5.32/];
my $flavors = {
    'base' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF"
# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

FROM amazon/aws-lambda-provided:alami

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'amazon/aws-lambda-provided:alami',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip",
            )
        },
        'tag' => sub {
            my $version = shift;
            return "base-$version";
        },
    },

    'run' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF"
FROM lambci/lambda:provided

USER root
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip
USER sbx_user1051
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'lambci/lambda:provided',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip",
            )
        },
        'tag' => sub {
            my $version = shift;
            return $version;
        },
    },

    'run.al2' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF"
# the provided.al2 image doesn't have curl and unzip,
# so we use the build-provided.al2 image here
FROM lambci/lambda:build-provided.al2
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip

FROM lambci/lambda:provided.al2
COPY --from=0 /opt /opt
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'lambci/lambda:provided.al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip",
            )
        },
        'tag' => sub {
            my $version = shift;
            return $version;
        },
    },
};

sub generate {
    chdir "$FindBin::Bin" or die "failed to chdir: $!";
    for my $perl(@$perl_versions) {
        for my $flavor(keys %$flavors) {
            next if $flavor =~ /[.]al2$/ && scalar(grep {$_ eq $perl} @$perl_versions_al2) == 0;
            mkpath("$perl/$flavor");
            open my $fh, '>', "$perl/$flavor/Dockerfile";
            print $fh $flavors->{$flavor}->{dockerfile}->($perl);
            close($fh);
        }
    }
}

sub build {
    # image dependencies
    my @images = (
        # for lambci provided
        'lambci/lambda:build-provided',
        'lambci/lambda:provided',

        # for lambci provided.al2
        'lambci/lambda:build-provided.al2',
        'lambci/lambda:provided.al2',

        # for container format
        'amazon/aws-lambda-provided:alami',
        'amazon/aws-lambda-provided:al2',
    );
    # for my $image(@images) {
    #     docker_pull($image);
    #     $state->{$image} = inspect_id($image);
    # }

    for my $perl(@$perl_versions) {
        for my $flavor(keys %$flavors) {
            next if $flavor =~ /[.]al2$/ && scalar(grep {$_ eq $perl} @$perl_versions_al2) == 0;

            my $settings = $flavors->{$flavor};
            my $tag = $settings->{tag}->($perl);
            chdir "$FindBin::Bin/$perl/$flavor" or die "failed to chdir: $!";
            docker('build', '-t', "perl:$tag", '.');
            docker('tag', "perl:$tag", "shogo82148/p5-aws-lambda:$tag");
            docker('push', "shogo82148/p5-aws-lambda:$tag");
            docker('tag', "perl:$tag", "public.ecr.aws/w2s0h5h2/p5-aws-lambda:$tag");
            docker('push', "public.ecr.aws/w2s0h5h2/p5-aws-lambda:$tag");
        }
    }
}

sub docker {
    system('docker', @_) == 0 or croak 'failed to run docker';
}

sub inspect_id {
    my $image = shift;
    return decode_json(run('docker', 'image', 'inspect', $image))->[0]->{Id};
}

sub fetch_etag {
    my $url = shift;
    my $headers = run('curl', '-I', $url);
    say $headers;
    $headers =~ /^ETag:\s*(\S+)/mi;
    return $1;
}

# a wrapper for system
sub run {
    my @args = @_;
    my $pid = open3(my $in, my $out, 0, @args);
    close($in);
    my $result = do { local $/; <$out> };
    waitpid($pid, 0);
    if ($? != 0) {
        my $code = $? >> 8;
        my $cmd = join ' ', @args;
        croak "`$cmd` exit code: $code, message: $result";
    }
    return $result;
}

my $subcommand = shift;
if ($subcommand eq 'generate') {
    generate();
}
if ($subcommand eq 'build') {
    build();
}

1
