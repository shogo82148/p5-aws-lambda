FROM lambci/lambda:build-provided

RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-26-runtime.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-26-paws.zip -o paws.zip && \
    unzip paws.zip && rm paws.zip
