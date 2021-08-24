FROM lambci/lambda:build-provided

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-34-runtime.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-34-paws.zip -o paws.zip && \
    unzip paws.zip && rm paws.zip
