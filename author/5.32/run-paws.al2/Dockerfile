# the provided.al2 image doesn't have curl and unzip,
# so we use the build-provided.al2 image here
FROM lambci/lambda:build-provided.al2
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-32-runtime-al2.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-32-paws-al2.zip -o paws.zip && \
    unzip paws.zip && rm paws.zip

FROM lambci/lambda:provided.al2
COPY --from=0 /opt /opt
