FROM shogo82148/p5-aws-lambda:base-5.44.al2023
# or if you want to use GitHub Container Registry.
# FROM ghcr.io/shogo82148/p5-aws-lambda:base-5.44.al2023
COPY handler.pl /var/task/
CMD [ "handler.handle" ]
