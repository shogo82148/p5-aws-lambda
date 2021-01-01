# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

FROM amazon/aws-lambda-provided:alami

RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-28-runtime.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
