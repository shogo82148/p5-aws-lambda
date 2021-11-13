FROM public.ecr.aws/shogo82148/lambda-provided:build-al2

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# workaround for "xlocale.h: No such file or directory"
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h && \
# build-provided.al2 lacks some development packages
    yum install -y expat-devel openssl openssl-devel && yum clean all

RUN cd /opt && \
    case $(uname -m) in "x86_64") ARCH=x86_64;; "aarch64") ARCH=arm64;; *) echo "unknown architecture: $(uname -m)"; exit 1;; esac && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-34-runtime-al2-$ARCH.zip -o runtime.zip && \
    unzip -o runtime.zip && rm runtime.zip
