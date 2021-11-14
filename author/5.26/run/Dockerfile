FROM public.ecr.aws/shogo82148/lambda-provided:alami

USER root
RUN cd /opt && \
    curl -sSL https://shogo82148-lambda-perl-runtime-us-east-1.s3.amazonaws.com/perl-5-26-runtime.zip -o runtime.zip && \
    unzip -o runtime.zip && rm runtime.zip
USER sbx_user1051
