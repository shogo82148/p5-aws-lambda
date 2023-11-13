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

my $perl_versions_al2 = [
    '5.38',
    '5.36',
];

my $perl_versions_al2023 = [
    '5.38',
];

my $flavors_al2 = {
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
ARG TARGETARCH
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
        'tag' => sub {
            my $version = shift;
            return "base-$version.al2";
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
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum install -y curl unzip
ARG TARGETARCH
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
        'tag' => sub {
            my $version = shift;
            return "base-$version-paws.al2";
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
        'tag' => sub {
            my $version = shift;
            return "build-$version.al2";
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
        'tag' => sub {
            my $version = shift;
            return "build-$version-paws.al2";
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
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM public.ecr.aws/shogo82148/lambda-provided:al2
COPY --from=0 /opt /opt
EOF
        },
        'tag' => sub {
            my $version = shift;
            return "$version.al2";
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
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum install -y curl unzip
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2-\$ARCH.zip -o paws.zip && \\
    unzip -o paws.zip && rm paws.zip

FROM public.ecr.aws/shogo82148/lambda-provided:al2
COPY --from=0 /opt /opt
COPY --from=1 /opt /opt
EOF
        },
        'tag' => sub {
            my $version = shift;
            return "$version-paws.al2";
        },
    },
};

my $flavors_al2023 = {
    'base.al2023' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

# the amazon/aws-lambda-provided:al2023 image doesn't have unzip,
# so we use the amazonlinux:2023 image here
# we just do unzip in this image
# so we use the build platform here.
FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2023
RUN dnf install -y unzip
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2023-\${ARCH}.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM public.ecr.aws/lambda/provided:al2023

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=0 /opt /opt
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
EOF
        },
        'tag' => sub {
            my $version = shift;
            return "base-$version.al2023";
        },
    },

    'base-paws.al2023' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

# the amazon/aws-lambda-provided:al2023 image doesn't have unzip,
# so we use the amazonlinux:2023 image here
FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2023
RUN dnf install -y unzip
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2023-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2023
RUN dnf install -y unzip
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2023-\$ARCH.zip -o paws.zip && \\
    unzip -o paws.zip && rm paws.zip

FROM public.ecr.aws/lambda/provided:al2023

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=0 /opt /opt
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
COPY --from=1 /opt /opt
EOF
        },
        'tag' => sub {
            my $version = shift;
            return "base-$version-paws.al2023";
        },
    },

    'build.al2023' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
FROM public.ecr.aws/shogo82148/lambda-provided:build-al2023

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# build-provided.al2023 lacks some development packages
RUN dnf install -y expat-devel openssl openssl-devel && dnf clean all

RUN cd /opt && \\
    case \$(uname -m) in "x86_64") ARCH=x86_64;; "aarch64") ARCH=arm64;; *) echo "unknown architecture: \$(uname -m)"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2023-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip
EOF
        },
        'tag' => sub {
            my $version = shift;
            return "build-$version.al2023";
        },
    },

    'build-paws.al2023' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF";
FROM public.ecr.aws/shogo82148/lambda-provided:build-al2023

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# build-provided.al2023 lacks some development packages
RUN dnf install -y expat-devel openssl openssl-devel && dnf clean all

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
        'tag' => sub {
            my $version = shift;
            return "build-$version-paws.al2023";
        },
    },

    'run.al2023' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF"
# the provided.al2023 image doesn't have unzip,
# so we use the build-provided.al2023 image here
FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2023
RUN dnf install -y unzip
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2023-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM public.ecr.aws/shogo82148/lambda-provided:al2023
COPY --from=0 /opt /opt
EOF
        },
        'tag' => sub {
            my $version = shift;
            return "$version.al2023";
        },
    },

    'run-paws.al2023' => {
        'dockerfile' => sub {
            my $version = shift;
            $version =~ s/[.]/-/;
            return <<"EOF"
# the provided.al2023 image doesn't have unzip,
# so we use the public.ecr.aws/amazonlinux/amazonlinux:2023 image here
FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2023
RUN dnf install -y unzip
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-runtime-al2023-\$ARCH.zip -o runtime.zip && \\
    unzip -o runtime.zip && rm runtime.zip

FROM --platform=\$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2023
RUN dnf install -y unzip
ARG TARGETARCH
RUN cd /opt && \\
    case \${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: \${TARGETARCH}"; exit 1;; esac && \\
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-$version-paws-al2023-\$ARCH.zip -o paws.zip && \\
    unzip -o paws.zip && rm paws.zip

FROM public.ecr.aws/shogo82148/lambda-provided:al2023
COPY --from=0 /opt /opt
COPY --from=1 /opt /opt
EOF
        },
        'tag' => sub {
            my $version = shift;
            return "$version-paws.al2023";
        },
    },
};

sub generate {
    chdir "$FindBin::Bin" or die "failed to chdir: $!";
    for my $perl(@$perl_versions_al2) {
        for my $flavor(sort keys %$flavors_al2) {
            mkpath("$perl/$flavor");
            open my $fh, '>', "$perl/$flavor/Dockerfile";
            print $fh $flavors_al2->{$flavor}->{dockerfile}->($perl);
            close($fh);
        }
    }

    for my $perl(@$perl_versions_al2023) {
        for my $flavor(sort keys %$flavors_al2023) {
            mkpath("$perl/$flavor");
            open my $fh, '>', "$perl/$flavor/Dockerfile";
            print $fh $flavors_al2023->{$flavor}->{dockerfile}->($perl);
            close($fh);
        }
    }
}

sub build {
    my $t = localtime;
    my $date = $t->ymd(".");

    for my $perl(@$perl_versions_al2) {
        for my $flavor(sort keys %$flavors_al2) {
            my $settings = $flavors_al2->{$flavor};
            my $tag = $settings->{tag}->($perl);
            say STDERR "building $tag...";
            chdir "$FindBin::Bin/$perl/$flavor" or die "failed to chdir: $!";
            for my $registory (qw(shogo82148/p5-aws-lambda public.ecr.aws/shogo82148/p5-aws-lambda ghcr.io/shogo82148/p5-aws-lambda)) {
                docker('buildx', 'build', '--platform', 'linux/amd64,linux/arm64', '--push', '-t', "$registory:$tag-$date", '.');
                docker('buildx', 'build', '--platform', 'linux/amd64', '--push', '-t', "$registory:$tag-$date-x86_64", '.');
                docker('buildx', 'build', '--platform', 'linux/arm64', '--push', '-t', "$registory:$tag-$date-arm64", '.');

                docker('buildx', 'build', '--platform', 'linux/amd64,linux/arm64', '--push', '-t', "$registory:$tag", '.');
                docker('buildx', 'build', '--platform', 'linux/amd64', '--push', '-t', "$registory:$tag-x86_64", '.');
                docker('buildx', 'build', '--platform', 'linux/arm64', '--push', '-t', "$registory:$tag-arm64", '.');
            }
        }
    }

    for my $perl(@$perl_versions_al2023) {
        for my $flavor(sort keys %$flavors_al2023) {
            my $settings = $flavors_al2023->{$flavor};
            my $tag = $settings->{tag}->($perl);
            say STDERR "building $tag...";
            chdir "$FindBin::Bin/$perl/$flavor" or die "failed to chdir: $!";
            for my $registory (qw(shogo82148/p5-aws-lambda public.ecr.aws/shogo82148/p5-aws-lambda ghcr.io/shogo82148/p5-aws-lambda)) {
                docker('buildx', 'build', '--platform', 'linux/amd64,linux/arm64', '--push', '-t', "$registory:$tag-$date", '.');
                docker('buildx', 'build', '--platform', 'linux/amd64', '--push', '-t', "$registory:$tag-$date-x86_64", '.');
                docker('buildx', 'build', '--platform', 'linux/arm64', '--push', '-t', "$registory:$tag-$date-arm64", '.');

                docker('buildx', 'build', '--platform', 'linux/amd64,linux/arm64', '--push', '-t', "$registory:$tag", '.');
                docker('buildx', 'build', '--platform', 'linux/amd64', '--push', '-t', "$registory:$tag-x86_64", '.');
                docker('buildx', 'build', '--platform', 'linux/arm64', '--push', '-t', "$registory:$tag-arm64", '.');
            }
        }
    }
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

1;
