FROM shogo82148/p5-aws-lambda:base-5.32-paws.al2
# or if you want to use ECR Public.
# FROM public.ecr.aws/w2s0h5h2/p5-aws-lambda:base-5.32-paws.al2
COPY handler.pl /var/task/
CMD [ "handler.handle" ]
