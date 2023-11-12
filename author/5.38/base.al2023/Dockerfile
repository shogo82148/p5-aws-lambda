# Base Image for Lambda
# You add your function code and dependencies to the base image and
# then run it as a container image on AWS Lambda.

# the amazon/aws-lambda-provided:al2023 image doesn't have unzip,
# so we use the amazonlinux:2023 image here
# we just do unzip in this image
# so we use the build platform here.
FROM --platform=$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2023
RUN dnf install -y unzip
ARG TARGETARCH
RUN cd /opt && \
    case ${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: ${TARGETARCH}"; exit 1;; esac && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-38-runtime-al2023-${ARCH}.zip -o runtime.zip && \
    unzip -o runtime.zip && rm runtime.zip

FROM public.ecr.aws/lambda/provided:al2023

# Use the custom runtime perl in preference to the system perl
ENV PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=0 /opt /opt
RUN ln -s /opt/bootstrap /var/runtime/bootstrap
