FROM lambci/lambda:provided

RUN cd /opt && \
    curl -sSL https://s3.amazonaws.com/shogo82148-lambda-perl-runtime-us-east-1/perl-5-26-runtime.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip
