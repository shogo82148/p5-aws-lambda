#!/usr/bin/env perl

use 5.032;
use strict;
use warnings;
use utf8;
use IPC::Open3;
use FindBin;
use Carp qw/croak/;
use JSON qw/decode_json encode_json/;
use File::Path qw/mkpath/;
use Time::Piece;

my $perl_versions = [qw/5.26 5.28 5.30 5.32 5.34/];
my $perl_versions_al2 = [qw/5.32 5.34/];
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

    'base.al2' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

# the amazon/aws-lambda-provided:al2 image doesn't have curl and unzip,
# so we use the build-provided.al2 image here
FROM lambci/lambda:build-provided.al2
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip

FROM amazon/aws-lambda-provided:al2
COPY --from=0 /opt /opt
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'amazon/aws-lambda-provided:al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip",
            );
        },
        'tag' => sub {
            my $version = shift;
            return "base-$version.al2";
        },
    },

    'base-paws' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

FROM amazon/aws-lambda-provided:alami

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip -o paws.zip && \\
    unzip paws.zip && rm paws.zip
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'amazon/aws-lambda-provided:alami',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip",
            );
        },
        'tag' => sub {
            my $version = shift;
            return "base-$version-paws";
        },
    },

    'base-paws.al2' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

# the amazon/aws-lambda-provided:al2 image doesn't have curl and unzip,
# so we use the build-provided.al2 image here
FROM lambci/lambda:build-provided.al2
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2.zip -o paws.zip && \\
    unzip paws.zip && rm paws.zip

FROM amazon/aws-lambda-provided:al2
COPY --from=0 /opt /opt
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'amazon/aws-lambda-provided:al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2.zip",
            );
        },
        'tag' => sub {
            my $version = shift;
            return "base-$version-paws.al2";
        },
    },

    'build' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
FROM lambci/lambda:build-provided

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'lambci/lambda:build-provided',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip",
            );
        },
        'tag' => sub {
            my $version = shift;
            return "build-$version";
        },
    },

    'build.al2' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
FROM lambci/lambda:build-provided.al2

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip && \\
    # workaround for "xlocale.h: No such file or directory"
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \\
    # build-provided.al2 lacks some development packages
    yum install -y expat-devel openssl openssl-devel && yum clean all
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'lambci/lambda:build-provided.al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip",
            );
        },
        'tag' => sub {
            my $version = shift;
            return "build-$version.al2";
        },
    },

    'build-paws' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
FROM lambci/lambda:build-provided

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip -o paws.zip && \\
    unzip paws.zip && rm paws.zip
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'lambci/lambda:build-provided',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip",
            );
        },
        'tag' => sub {
            my $version = shift;
            return "build-$version-paws";
        },
    },

    'build-paws.al2' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
FROM lambci/lambda:build-provided.al2

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip && \\
    # workaround for "xlocale.h: No such file or directory"
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \\
    # build-provided.al2 lacks some development packages
    yum install -y expat-devel openssl openssl-devel && yum clean all
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2.zip -o paws.zip && \\
    unzip paws.zip && rm paws.zip
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'lambci/lambda:build-provided.al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2.zip",
            );
        },
        'tag' => sub {
            my $version = shift;
            return "build-$version-paws.al2";
        },
    },

    'run' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
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
            );
        },
        'tag' => sub {
            my $version = shift;
            return "$version";
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
            );
        },
        'tag' => sub {
            my $version = shift;
            return "$version.al2";
        },
    },

    'run-paws' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF"
FROM lambci/lambda:provided

USER root
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip runtime.zip && rm runtime.zip
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip -o paws.zip && \\
    unzip paws.zip && rm paws.zip
USER sbx_user1051
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'lambci/lambda:provided',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip",
            );
        },
        'tag' => sub {
            my $version = shift;
            return "$version-paws";
        },
    },

    'run-paws.al2' => {
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
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2.zip -o paws.zip && \\
    unzip paws.zip && rm paws.zip

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
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2.zip",
            );
        },
        'tag' => sub {
            my $version = shift;
            return "$version-paws.al2";
        },
    },
};

sub generate {
    chdir "$FindBin::Bin" or die "failed to chdir: $!";
    for my $perl(@$perl_versions) {
        for my $flavor(sort keys %$flavors) {
            next if $flavor =~ /[.]al2$/ && scalar(grep {$_ eq $perl} @$perl_versions_al2) == 0;
            mkpath("$perl/$flavor");
            open my $fh, '>', "$perl/$flavor/Dockerfile";
            print $fh $flavors->{$flavor}->{dockerfile}->($perl);
            close($fh);
        }
    }
}

my $current_state = {};
my $state = {};

sub build {
    # load current state
    $current_state = load_state();

    my $t = localtime;
    my $date = $t->ymd(".");

    check_updates();

    for my $perl(@$perl_versions) {
        for my $flavor(sort keys %$flavors) {
            next if $flavor =~ /[.]al2$/ && scalar(grep {$_ eq $perl} @$perl_versions_al2) == 0;

            my $settings = $flavors->{$flavor};
            my $tag = $settings->{tag}->($perl);
            if (!needs_build($settings->{dependencies}->($perl))) {
                say STDERR "no need to build $tag, skipping.";
                next;
            }
            say STDERR "building $tag...";
            chdir "$FindBin::Bin/$perl/$flavor" or die "failed to chdir: $!";
            docker('build', '-t', "perl:$tag", '.');

            docker('tag', "perl:$tag", "shogo82148/p5-aws-lambda:$tag");
            docker('push', "shogo82148/p5-aws-lambda:$tag");
            docker('tag', "perl:$tag", "shogo82148/p5-aws-lambda:$tag-$date");
            docker('push', "shogo82148/p5-aws-lambda:$tag-$date");

            docker('tag', "perl:$tag", "public.ecr.aws/shogo82148/p5-aws-lambda:$tag");
            docker('push', "public.ecr.aws/shogo82148/p5-aws-lambda:$tag");
            docker('tag', "perl:$tag", "public.ecr.aws/shogo82148/p5-aws-lambda:$tag-$date");
            docker('push', "public.ecr.aws/shogo82148/p5-aws-lambda:$tag-$date");
        }
    }

    save_state($state);
}

sub check_updates {
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
    for my $image(@images) {
        docker('pull', $image);
        $state->{$image} = inspect_id($image);
    }

    for my $perl(@$perl_versions) {
        my $version = $perl =~ s/[.]/-/r;
        my $runtime = "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip";
        $state->{$runtime} = fetch_etag($runtime);
        my $paws = "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip";
        $state->{$paws} = fetch_etag($paws);
    }

    for my $perl(@$perl_versions_al2) {
        my $version = $perl =~ s/[.]/-/r;
        my $runtime = "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2.zip";
        $state->{$runtime} = fetch_etag($runtime);
        my $paws = "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2.zip";
        $state->{$paws} = fetch_etag($paws);
    }
}

sub needs_build {
    my @deps = @_;
    for my $dep(@deps) {
        my $current = $current_state->{$dep};
        my $new = $state->{$dep};
        if (!$current || $current ne $new) {
            return 1;
        }
    }
    return 0;
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

sub load_state {
    open my $fh, '<', "$FindBin::Bin/state.json" or return {};
    my $data = do { local $/; <$fh> };
    close($fh);
    return decode_json($data);
}

sub save_state {
    my $state = shift;
    my $json = JSON->new->utf8(1)->pretty(1)->canonical(1);
    open my $fh, '>', "$FindBin::Bin/state.json" or return {};
    print $fh $json->encode($state);
    close($fh);
}

my $subcommand = shift;
if ($subcommand eq 'generate') {
    generate();
}
if ($subcommand eq 'build') {
    build();
}

1
