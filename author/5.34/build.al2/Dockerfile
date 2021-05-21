FROM lambci/lambda:build-provided.al2

RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-34-runtime-al2.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip && \
    # workaround for "xlocale.h: No such file or directory"
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    # build-provided.al2 lacks some development packages
    yum install -y expat-devel openssl openssl-devel && yum clean all
