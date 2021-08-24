# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

# the amazon/aws-lambda-provided:al2 image doesn't have curl and unzip,
# so we use the build-provided.al2 image here
FROM lambci/lambda:build-provided.al2
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-32-runtime-al2.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip

FROM amazon/aws-lambda-provided:al2

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=0 /opt /opt
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
