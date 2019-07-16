FROM lambci/lambda:build-provided

RUN cd /opt && \
    curl -sSL https://shogo82148-test.s3-ap-northeast-1.amazonaws.com/perl-5-30-runtime.zip -o runtime.zip && \
    unzip runtime.zip && rm runtime.zip
RUN cd /opt && \
    curl -sSL https://shogo82148-test.s3-ap-northeast-1.amazonaws.com/perl-5-30-paws.zip -o paws.zip && \
    unzip paws.zip && rm paws.zip
