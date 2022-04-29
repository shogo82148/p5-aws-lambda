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

my $perl_versions = [
    '5.32',
    '5.34',
];
my $perl_versions_al2 = [
    '5.32',
    '5.34',
];

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

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip
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

# the amazon/aws-lambda-provided:al2 image doesn't have unzip,
# so we use the amazonlinux:2 image here
# we just do unzip in this image
# so we use the build platform here.
FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum install -y curl unzip
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-\${ARCH}.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM public.ecr.aws/lambda/provided:al2

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=0 /opt /opt
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/lambda/provided:al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-x86_64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-arm64.zip",
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

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip -o paws.zip && \\
    unzip -o paws.zip && rm paws.zip
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

# the amazon/aws-lambda-provided:al2 image doesn't have unzip,
# so we use the amazonlinux:2 image here
FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum install -y curl unzip
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum install -y curl unzip
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-\$ARCH.zip -o paws.zip && \\
    unzip -o paws.zip && rm paws.zip

FROM public.ecr.aws/lambda/provided:al2

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=0 /opt /opt
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
COPY --from=1 /opt /opt
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/lambda/provided:al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-x86_64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-arm64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-x86_64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-arm64.zip",
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
FROM public.ecr.aws/shogo82148/lambda-provided:build-alami

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/shogo82148/lambda-provided:build-alami',
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
FROM public.ecr.aws/shogo82148/lambda-provided:build-al2

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# workaround for "xlocale.h: No such file or directory"
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h && \\
# build-provided.al2 lacks some development packages
    yum install -y expat-devel openssl openssl-devel && yum clean all

RUN cd /opt && \\
    case \$(uname -m) in "x86_64") ARCH=x86_64;; "aarch64") ARCH=arm64;; *) echo "unknown architecture: \$(uname -m)"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/shogo82148/lambda-provided:build-al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-x64_64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-arm64.zip",
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
FROM public.ecr.aws/shogo82148/lambda-provided:build-alami

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip -o paws.zip && \\
    unzip -o paws.zip && rm paws.zip
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/shogo82148/lambda-provided:build-alami',
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
FROM public.ecr.aws/shogo82148/lambda-provided:build-al2

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# workaround for "xlocale.h: No such file or directory"
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h && \\
# build-provided.al2 lacks some development packages
    yum install -y expat-devel openssl openssl-devel && yum clean all

RUN cd /opt && \\
    case \$(uname -m) in "x86_64") ARCH=x86_64;; "aarch64") ARCH=arm64;; *) echo "unknown architecture: \$(uname -m)"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip
RUN cd /opt && \\
    case \$(uname -m) in "x86_64") ARCH=x86_64;; "aarch64") ARCH=arm64;; *) echo "unknown architecture: \$(uname -m)"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-\$ARCH.zip -o paws.zip && \\
    unzip -o paws.zip && rm paws.zip
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/shogo82148/lambda-provided:build-al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-x84_64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-arm64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-x86_64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-arm64.zip",
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
FROM public.ecr.aws/shogo82148/lambda-provided:alami

USER root
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip
USER sbx_user1051
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/shogo82148/lambda-provided:alami',
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
FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum install -y curl unzip
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM public.ecr.aws/shogo82148/lambda-provided:al2
COPY --from=0 /opt /opt
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/shogo82148/lambda-provided:al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-x86_64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-arm64.zip",
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
FROM public.ecr.aws/shogo82148/lambda-provided:alami

USER root
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip
RUN cd /opt && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip -o paws.zip && \\
    unzip -o paws.zip && rm paws.zip
USER sbx_user1051
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/shogo82148/lambda-provided:alami',
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
# so we use the public.ecr.aws/amazonlinux/amazonlinux:2 image here
FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum install -y curl unzip
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum install -y curl unzip
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-\$ARCH.zip -o paws.zip && \\
    unzip -o paws.zip && rm paws.zip

FROM public.ecr.aws/shogo82148/lambda-provided:al2
COPY --from=0 /opt /opt
COPY --from=1 /opt /opt
EOF
        },
        'dependencies' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return (
                'public.ecr.aws/shogo82148/lambda-provided:al2',
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-x86_64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-arm64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-x86_64.zip",
                "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-arm64.zip",
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
            my $is_al2 = $flavor =~ /[.]al2$/;
            next if $is_al2 && scalar(grep {$_ eq $perl} @$perl_versions_al2) == 0;
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

    say STDERR "checking updates...";
    check_updates();

    for my $perl(@$perl_versions) {
        for my $flavor(sort keys %$flavors) {
            my $is_al2 = $flavor =~ /[.]al2$/;
            next if $is_al2 && scalar(grep {$_ eq $perl} @$perl_versions_al2) == 0;

            my $settings = $flavors->{$flavor};
            my $tag = $settings->{tag}->($perl);
            if (!needs_build($settings->{dependencies}->($perl))) {
                say STDERR "no need to build $tag, skipping.";
                next;
            }
            say STDERR "building $tag...";
            chdir "$FindBin::Bin/$perl/$flavor" or die "failed to chdir: $!";
            for my $registory (qw(shogo82148/p5-aws-lambda public.ecr.aws/shogo82148/p5-aws-lambda ghcr.io/shogo82148/p5-aws-lambda)) {
                if ($is_al2) {
                    docker('buildx', 'build', '--platform', 'linux/amd64,linux/arm64', '--push', '-t', "$registory:$tag-$date", '.');
                    docker('buildx', 'build', '--platform', 'linux/amd64', '--push', '-t', "$registory:$tag-$date-x86_64", '.');
                    docker('buildx', 'build', '--platform', 'linux/arm64', '--push', '-t', "$registory:$tag-$date-arm64", '.');

                    docker('buildx', 'build', '--platform', 'linux/amd64,linux/arm64', '--push', '-t', "$registory:$tag", '.');
                    docker('buildx', 'build', '--platform', 'linux/amd64', '--push', '-t', "$registory:$tag-x86_64", '.');
                    docker('buildx', 'build', '--platform', 'linux/arm64', '--push', '-t', "$registory:$tag-arm64", '.');
                } else {
                    docker('buildx', 'build', '--platform', 'linux/amd64', '--push', '-t', "$registory:$tag-$date", '.');
                    docker('buildx', 'build', '--platform', 'linux/amd64', '--push', '-t', "$registory:$tag", '.');
                }
            }
        }
    }

    save_state($state);
}

sub check_updates {
    # image dependencies
    my @images = (
        # for lambci provided
        'public.ecr.aws/shogo82148/lambda-provided:build-alami',
        'public.ecr.aws/shogo82148/lambda-provided:alami',

        # for lambci provided.al2
        'public.ecr.aws/shogo82148/lambda-provided:build-al2',
        'public.ecr.aws/shogo82148/lambda-provided:al2',

        # for container format
        'amazon/aws-lambda-provided:alami',
        'amazon/aws-lambda-provided:al2',

        # for aws provided images
        'public.ecr.aws/amazonlinux/amazonlinux:2',
        'public.ecr.aws/lambda/provided:al2',
    );
    for my $image(@images) {
        say STDERR "inspect $image";
        $state->{$image} = inspect_id($image);
    }

    for my $perl(@$perl_versions) {
        say STDERR "$perl on provided";
        my $version = $perl =~ s/[.]/-/r;
        my $runtime = "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime.zip";
        $state->{$runtime} = fetch_etag($runtime);
        my $paws = "https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws.zip";
        $state->{$paws} = fetch_etag($paws);
    }

    for my $perl(@$perl_versions_al2) {
        say STDERR "$perl on provided.al2";
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
    if (system('docker', @_) == 0) {
        return;
    }
    print STDERR "failed to build, try...";
    sleep(5);
    if (system('docker', @_) == 0) {
        return;
    }
    print STDERR "failed to build, try...";
    sleep(10);
    if (system('docker', @_) == 0) {
        return;
    }
    croak 'gave up, failed to run docker';
}

sub inspect_id {
    my $image = shift;
    my $manifest = decode_json(run('docker', 'manifest', 'inspect', $image));
    my $mediaType = lc $manifest->{mediaType};
    if ($mediaType eq 'application/vnd.docker.distribution.manifest.v2+json') {
        return $manifest->{config}{digest};
    }
    if ($mediaType eq 'application/vnd.docker.distribution.manifest.list.v2+json') {
        return join "\n", sort map {$_->{digest}} @{$manifest->{manifests}};
    }
    return '';
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

1;
