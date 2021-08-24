# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

FROM amazon/aws-lambda-provided:alami

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-34-runtime.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
