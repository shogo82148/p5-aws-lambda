FROM lambci/lambda:build-provided.al2

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-34-runtime-al2.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip && \
    # workaround for "xlocale.h: No such file or directory"
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    # build-provided.al2 lacks some development packages
    yum install -y expat-devel openssl openssl-devel && yum clean all
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-34-paws-al2.zip -o paws.zip && \
    unzip paws.zip && rm paws.zip
