FROM lambci/lambda:provided

USER root
RUN cd /opt && \
    curl -sSL https://s3.amazonaws.com/shogo82148-lambda-perl-runtime-us-east-1/perl-5-30-runtime.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip
RUN cd /opt && \
    curl -sSL https://s3.amazonaws.com/shogo82148-lambda-perl-runtime-us-east-1/perl-5-30-paws.zip -o paws.zip && \
    unzip paws.zip && rm paws.zip
USER sbx_user1051
