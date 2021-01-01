# An Example of Custom Docker Images

Build the hello-perl container image locally:

    $ docker build -t hello-perl .

To upload the container image, you need to create a new ECR repository in your account and tag the local image to push it to ECR.

    $ aws ecr create-repository --repository-name hello-perl --image-scanning-configuration scanOnPush=true
    $ docker tag hello-perl:latest 123412341234.dkr.ecr.sa-east-1.amazonaws.com/hello-perl:latest
    $ aws ecr get-login-password | docker login --username AWS --password-stdin 123412341234.dkr.ecr.sa-east-1.amazonaws.com
    $ docker push 123412341234.dkr.ecr.sa-east-1.amazonaws.com/hello-perl:latest

Finally, create new function using awscli.

    $ aws --region "$REGION" --profile "$PROFILE" lambda create-function \
        --function-name "hello-perl" \
        --code ImageUri=123412341234.dkr.ecr.sa-east-1.amazonaws.com/hello-perl:latest \
        --handler "handler.handle" \
        --runtime provided.al2 \
        --role arn:aws:iam::xxxxxxxxxxxx:role/service-role/lambda-custom-runtime-perl-role
