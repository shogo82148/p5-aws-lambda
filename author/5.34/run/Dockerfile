FROM lambci/lambda:provided

USER root
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-34-runtime.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip
USER sbx_user1051
