# the provided.al2023 image doesn't have unzip,
# so we use the build-provided.al2023 image here
FROM --platform=$BUILDPLATFORM public.ecr.aws/amazonlinux/amazonlinux:2023
RUN dnf install -y unzip
ARG TARGETARCH
RUN cd /opt && \
    case ${TARGETARCH} in "amd64") ARCH=x86_64;; "arm64") ARCH=arm64;; *) echo "unknown architecture: ${TARGETARCH}"; exit 1;; esac && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-38-runtime-al2023-$ARCH.zip -o runtime.zip && \
    unzip -o runtime.zip && rm runtime.zip

FROM public.ecr.aws/shogo82148/lambda-provided:al2023
COPY --from=0 /opt /opt
