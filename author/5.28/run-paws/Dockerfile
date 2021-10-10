FROM lambci/lambda:provided

USER root
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-28-runtime.zip -o runtime.zip && \
    unzip -o runtime.zip && rm runtime.zip
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-28-paws.zip -o paws.zip && \
    unzip -o paws.zip && rm paws.zip
USER sbx_user1051
