[![Actions Status](https://github.com/shogo82148/p5-aws-lambda/workflows/Test/badge.svg)](https://github.com/shogo82148/p5-aws-lambda/actions)
# NAME

AWS::Lambda - It's Perl support for AWS Lambda Custom Runtime.

# SYNOPSIS

Save the following Perl script as `handler.pl`.

    sub handle {
        my ($payload, $context) = @_;
        return $payload;
    }
    1;

and then, zip the script.

    $ zip handler.zip handler.pl

Finally, create new function using awscli.

    $ aws --region "$REGION" --profile "$PROFILE" lambda create-function \
        --function-name "hello-perl" \
        --zip-file "fileb://handler.zip" \
        --handler "handler.handle" \
        --runtime provided.al2 \
        --role arn:aws:iam::xxxxxxxxxxxx:role/service-role/lambda-custom-runtime-perl-role \
        --layers "arn:aws:lambda:$REGION:445285296882:layer:perl-5-34-runtime-al2-x86_64:4"

# DESCRIPTION

This package makes it easy to run AWS Lambda Functions written in Perl.

## Use Pre-built Public Lambda Layers

1. Login to your AWS Account and go to the Lambda Console.
2. Create a new function and give it a name and an IAM Role.
3. For the "Runtime" selection, select **Provide your own bootstrap on Amazon Linux 2**.
4. In the "Designer" section of your function dashboard, select the **Layers** box.
5. Scroll down to the "Layers" section and click **Add a layer**.
6. Select the **Provide a layer version ARN** option, then copy/paste the Layer ARN for your region.
7. Click the **Add** button.
8. Click **Save** in the upper right.
9. Upload your code and start using Perl in AWS Lambda!

You can get the layer ARN in your script by using `get_layer_info`.

    use AWS::Lambda;
    my $info = AWS::Lambda::get_layer_info_al2(
        "5.34",      # Perl Version
        "us-east-1", # Region
        "x86_64",    # Architecture ("x86_64" or "arm64", optional, the default is "x86_64")
    );
    say $info->{runtime_arn};     # arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:4
    say $info->{runtime_version}; # 4
    say $info->{paws_arn}         # arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-paws-al2-x86_64:5
    say $info->{paws_version}     # 5,

Or, you can use following one-liner.

    perl -MAWS::Lambda -e 'AWS::Lambda::print_runtime_arn_al2("5.34", "us-east-1")'
    perl -MAWS::Lambda -e 'AWS::Lambda::print_paws_arn_al2("5.34", "us-east-1")'

The list of all available layer ARN is here:

- Perl 5.34
    - x86\_64 architecture
        - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
        - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
        - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
        - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
        - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-runtime-al2-x86_64:2`
        - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
        - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
        - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
        - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
        - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
        - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3`
        - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:4`
    - arm64 architecture
        - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
        - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
        - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
        - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
        - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
        - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
        - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
        - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
        - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
        - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-runtime-al2-arm64:3`
- Perl 5.32
    - x86\_64 architecture
        - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
        - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
        - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
        - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
        - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-runtime-al2-x86_64:2`
        - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
        - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
        - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
        - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
        - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
        - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3`
        - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:4`
    - arm64 architecture
        - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3`
        - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3`
        - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3`
        - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime-al2-arm64:3`
        - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3`
        - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3`
        - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime-al2-arm64:3`
        - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3`
        - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime-al2-arm64:3`
        - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime-al2-arm64:3`

## Use Pre-built Zip Archives

1. Login to your AWS Account and go to the Lambda Console.
2. Create a new layer and give it a name.
3. For the "Code entry type" selection, select **Upload a file from Amazon S3**.
4. In the "License" section, input [https://github.com/shogo82148/p5-aws-lambda/blob/main/LICENSE](https://github.com/shogo82148/p5-aws-lambda/blob/main/LICENSE).
5. Click **Create** button.
6. Use the layer created. For detail, see Use Prebuilt Public Lambda Layer section.

URLs for Zip archives are here.

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime-al2-$ARCHITECTURE.zip`

## Use Pre-built Docker Images

Prebuilt Docker Images based on [https://gallery.ecr.aws/lambda/provided](https://gallery.ecr.aws/lambda/provided) are available.
You can pull from [https://gallery.ecr.aws/shogo82148/p5-aws-lambda](https://gallery.ecr.aws/shogo82148/p5-aws-lambda) or [https://hub.docker.com/r/shogo82148/p5-aws-lambda](https://hub.docker.com/r/shogo82148/p5-aws-lambda),
build your custom images and deploy them to AWS Lambda.

Here is an example of Dockerfile.

    FROM shogo82148/p5-aws-lambda:base-5.34.al2
    # or if you want to use ECR Public.
    # FROM public.ecr.aws/shogo82148/p5-aws-lambda:base-5.34.al2
    COPY handler.pl /var/task/
    CMD [ "handler.handle" ]

Build the hello-perl container image locally:

    $ docker build -t hello-perl .

To check if this is working, start the container image locally using the Lambda Runtime Interface Emulator:

    $ docker run -p 9000:8080 hello-perl:latest

Now, you can test a function invocation with cURL.

    $ curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

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

## Run in Local using Docker

Prebuilt Docker Images based on [https://hub.docker.com/r/lambci/lambda/](https://hub.docker.com/r/lambci/lambda/) are available.
You can pull from [https://gallery.ecr.aws/shogo82148/p5-aws-lambda](https://gallery.ecr.aws/shogo82148/p5-aws-lambda) or [https://hub.docker.com/r/shogo82148/p5-aws-lambda](https://hub.docker.com/r/shogo82148/p5-aws-lambda),
and build zip archives to deploy.

    # Install the dependency.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.34.al2 \
        cpanm --notest --local-lib extlocal --no-man-pages --installdeps .

    # run an event.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.34.al2 \
        handler.handle '{"some":"event"}'

## Pre-installed modules

The following modules are pre-installed for convenience.

- [AWS::Lambda](https://metacpan.org/pod/AWS%3A%3ALambda)
- [AWS::XRay](https://metacpan.org/pod/AWS%3A%3AXRay)
- [JSON](https://metacpan.org/pod/JSON)
- [Cpanel::JSON::XS](https://metacpan.org/pod/Cpanel%3A%3AJSON%3A%3AXS)
- [JSON::MaybeXS](https://metacpan.org/pod/JSON%3A%3AMaybeXS)
- [YAML](https://metacpan.org/pod/YAML)
- [YAML::Tiny](https://metacpan.org/pod/YAML%3A%3ATiny)
- [YAML::XS](https://metacpan.org/pod/YAML%3A%3AXS)
- [Net::SSLeay](https://metacpan.org/pod/Net%3A%3ASSLeay)
- [IO::Socket::SSL](https://metacpan.org/pod/IO%3A%3ASocket%3A%3ASSL)
- [Mozilla::CA](https://metacpan.org/pod/Mozilla%3A%3ACA)

[Paws](https://metacpan.org/pod/Paws) is optional. See the "Paws SUPPORT" section.

## AWS X-Ray SUPPORT

[AWS X-Ray](https://aws.amazon.com/xray/) is a service that collects data about requests that your application serves.
You can trace AWS Lambda requests and sends segment data with pre-install module [AWS::XRay](https://metacpan.org/pod/AWS%3A%3AXRay).

    use utf8;
    use warnings;
    use strict;
    use AWS::XRay qw/ capture /;

    sub handle {
        my ($payload, $context) = @_;
        capture "myApp" => sub {
            capture "nested" => sub {
                # do something ...
            };
        };
        capture "another" => sub {
            # do something ...
        };
        return;
    }

    1;

# Paws SUPPORT

If you want to call AWS API from your Lambda function,
you can use a pre-built Lambda Layer for [Paws](https://metacpan.org/pod/Paws) - A Perl SDK for AWS (Amazon Web Services) APIs.

## Use Prebuilt Public Lambda Layers

Add the perl-runtime layer and the perl-paws layer into your lambda function.

    aws --region "$REGION" --profile "$PROFILE" lambda create-function \
        --function-name "hello-perl" \
        --zip-file "fileb://handler.zip" \
        --handler "handler.handle" \
        --runtime provided.al2 \
        --role arn:aws:iam::xxxxxxxxxxxx:role/service-role/lambda-custom-runtime-perl-role \
        --layers \
            "arn:aws:lambda:$REGION:445285296882:layer:perl-5-34-runtime-al2-x86_64:4" \
            "arn:aws:lambda:$REGION:445285296882:layer:perl-5-34-paws-al2-x86_64:5"

Now, you can use [Paws](https://metacpan.org/pod/Paws) to call AWS API from your Lambda function.

    use Paws;
    my $obj = Paws->service('...');
    my $res = $obj->MethodCall(Arg1 => $val1, Arg2 => $val2);
    print $res->AttributeFromResult;

The list of all available layer ARN is here:

- Perl 5.34
    - x86\_64 architecture
        - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
        - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
        - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
        - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
        - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-paws-al2-x86_64:2`
        - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
        - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
        - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
        - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
        - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
        - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-paws-al2-x86_64:4`
        - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-paws-al2-x86_64:5`
    - arm64 architecture
        - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-paws-al2-arm64:4`
        - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-paws-al2-arm64:4`
        - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-paws-al2-arm64:4`
        - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-paws-al2-arm64:4`
        - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-paws-al2-arm64:4`
        - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-paws-al2-arm64:4`
        - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-paws-al2-arm64:4`
        - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-paws-al2-arm64:4`
        - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-paws-al2-arm64:4`
        - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-paws-al2-arm64:4`
- Perl 5.32
    - x86\_64 architecture
        - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
        - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
        - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
        - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
        - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-paws-al2-x86_64:2`
        - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
        - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
        - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
        - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
        - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
        - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-paws-al2-x86_64:4`
        - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-paws-al2-x86_64:5`
    - arm64 architecture
        - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-paws-al2-arm64:4`
        - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-paws-al2-arm64:4`
        - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-paws-al2-arm64:4`
        - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-paws-al2-arm64:4`
        - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-paws-al2-arm64:4`
        - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-paws-al2-arm64:4`
        - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-paws-al2-arm64:4`
        - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws-al2-arm64:4`
        - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-paws-al2-arm64:4`
        - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-paws-al2-arm64:4`

URLs for Zip archive are here.

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws-al2-$ARCHITECTURE.zip`

## Use Prebuilt Docker Images for Paws

use the `base-$VERSION-paws.al2` tag on [https://gallery.ecr.aws/shogo82148/p5-aws-lambda](https://gallery.ecr.aws/shogo82148/p5-aws-lambda) or [https://hub.docker.com/r/shogo82148/p5-aws-lambda](https://hub.docker.com/r/shogo82148/p5-aws-lambda).

    FROM shogo82148/p5-aws-lambda:base-5.34-paws.al2
    # or if you want to use ECR Public.
    # FROM public.ecr.aws/shogo82148/p5-aws-lambda:base-5.34-paws.al2
    COPY handler.pl /var/task/
    CMD [ "handler.handle" ]

## Run in Local using Docker for Paws

use the `build-$VERSION-paws.al2` and `$VERSION-paws.al2` tag on [https://gallery.ecr.aws/shogo82148/p5-aws-lambda](https://gallery.ecr.aws/shogo82148/p5-aws-lambda) or [https://hub.docker.com/r/shogo82148/p5-aws-lambda](https://hub.docker.com/r/shogo82148/p5-aws-lambda).

    # Install the dependency.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.34-paws.al2 \
        cpanm --notest --local-lib extlocal --no-man-pages --installdeps .

    # run an event.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.34-paws.al2 \
        handler.handle '{"some":"event"}'

# CREATE MODULE LAYER

To create custom module layer such as the Paws Layer,
install the modules into `/opt/lib/perl5/site_perl` in the layer.

    # Create Some::Module Layer
    docker run --rm \
        -v $(PWD):/var/task \
        -v $(PATH_TO_LAYER_DIR)/lib/perl5/site_perl:/opt/lib/perl5/site_perl \
        shogo82148/p5-aws-lambda:build-5.34.al2 \
        cpanm --notest --no-man-pages Some::Module
    cd $(PATH_TO_LAYER_DIR) && zip -9 -r $(PATH_TO_DIST)/some-module.zip .

# MAINTENANCE AND SUPPORT

Supported Perl versions are the same as those officially supported by the Perl community ([perlpolicy](https://metacpan.org/pod/perlpolicy)).
It means that we support the two most recent stable release series.

# LEGACY CUSTOM RUNTIME ON AMAZON LINUX

We also provide the layers for legacy custom runtime as known as "provided".
These layers are only for backward compatibility.
We recommend to migrate to Amazon Linux 2.
We may stop maintenance without any notice.

## Pre-built Public Lambda Layers for Amazon Linux

The list of all available layer ARN is here:

- Perl 5.34
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-runtime:6`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-runtime:6`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-runtime:6`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-runtime:6`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-runtime:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-runtime:6`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-runtime:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-runtime:6`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-runtime:6`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime:6`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-runtime:6`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-runtime:5`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-runtime:6`
- Perl 5.32
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime:7`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime:7`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime:8`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime:7`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-runtime:5`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime:8`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime:8`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime:8`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-runtime:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime:7`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime:8`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-runtime:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime:7`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime:8`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime:8`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime:7`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime:7`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime:7`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime:8`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime:8`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime:7`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime:8`
- Perl 5.30
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-30-runtime:7`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-30-runtime:14`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-30-runtime:15`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-30-runtime:14`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-30-runtime:5`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-30-runtime:15`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-30-runtime:15`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-30-runtime:15`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-30-runtime:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-30-runtime:14`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-30-runtime:15`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-30-runtime:7`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-30-runtime:15`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-30-runtime:15`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-30-runtime:14`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-30-runtime:12`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-30-runtime:14`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-30-runtime:15`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-30-runtime:15`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-30-runtime:14`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-30-runtime:15`
- Perl 5.28
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-28-runtime:7`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-28-runtime:13`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-28-runtime:21`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-28-runtime:20`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-28-runtime:5`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-28-runtime:21`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-28-runtime:21`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-28-runtime:21`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-28-runtime:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-28-runtime:20`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-28-runtime:21`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-28-runtime:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-28-runtime:7`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-28-runtime:21`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-28-runtime:21`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-28-runtime:20`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-28-runtime:11`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-28-runtime:20`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-28-runtime:21`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-28-runtime:21`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-28-runtime:20`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-28-runtime:21`
- Perl 5.26
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-26-runtime:7`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-26-runtime:14`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-26-runtime:22`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-26-runtime:21`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-26-runtime:5`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-26-runtime:22`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-26-runtime:22`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-26-runtime:22`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-26-runtime:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-26-runtime:21`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-26-runtime:22`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-26-runtime:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-26-runtime:7`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-26-runtime:22`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-26-runtime:21`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-26-runtime:20`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-26-runtime:11`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-26-runtime:20`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-26-runtime:21`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-26-runtime:21`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-26-runtime:20`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-26-runtime:21`

And Paws layers:

- Perl 5.34
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-paws:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-paws:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-paws:5`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-paws:5`
- Perl 5.32
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-paws:6`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-paws:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-paws:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-paws:8`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-paws:8`
- Perl 5.30
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-30-paws:8`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-30-paws:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-30-paws:8`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-30-paws:11`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-30-paws:12`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-30-paws:12`
- Perl 5.28
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-28-paws:8`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-28-paws:6`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-28-paws:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-28-paws:8`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-28-paws:10`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-28-paws:11`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-28-paws:11`
- Perl 5.26
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-26-paws:8`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-26-paws:12`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-26-paws:12`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-26-paws:12`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-26-paws:12`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-26-paws:12`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-26-paws:12`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-26-paws:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-26-paws:12`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-26-paws:12`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-26-paws:8`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-26-paws:12`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-26-paws:11`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-26-paws:11`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-26-paws:10`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-26-paws:11`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-26-paws:11`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-26-paws:11`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-26-paws:11`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-26-paws:11`

## Pre-built Zip Archives for Amazon Linux

URLs of zip archives are here:

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime.zip`

And Paws:

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws.zip`

# LEGACY CUSTOM RUNTIME ON AMAZON LINUX 2

Previously, we provided the layers that named without CPU architectures.
These layers are compatible with x86\_64 and only for backward compatibility.
We recommend to specify the CPU architecture.
We may stop maintenance without any notice.

## Pre-built Legacy Public Lambda Layers for Amazon Linux 2

The list of all available layer ARN is here:

- Perl 5.34
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-runtime-al2:6`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-runtime-al2:6`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-runtime-al2:6`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-runtime-al2:6`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-runtime-al2:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-runtime-al2:6`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-runtime-al2:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-runtime-al2:6`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-runtime-al2:6`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime-al2:6`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-runtime-al2:6`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-runtime-al2:5`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-runtime-al2:6`
- Perl 5.32
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime-al2:7`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime-al2:7`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime-al2:8`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime-al2:7`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-runtime-al2:5`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime-al2:8`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime-al2:8`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime-al2:8`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-runtime-al2:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime-al2:7`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime-al2:8`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-runtime-al2:3`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime-al2:7`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime-al2:8`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime-al2:8`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime-al2:7`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime-al2:7`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime-al2:7`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2:8`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime-al2:8`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime-al2:7`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime-al2:8`

And Paws layers:

- Perl 5.34
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-paws-al2:7`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-paws-al2:7`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-paws-al2:7`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-paws-al2:7`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-paws-al2:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-paws-al2:7`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-paws-al2:4`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-paws-al2:7`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-paws-al2:7`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-paws-al2:7`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-paws-al2:7`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-paws-al2:6`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-paws-al2:7`
- Perl 5.32
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-paws-al2:9`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-paws-al2:9`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-paws-al2:10`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-paws-al2:9`
    - `arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-paws-al2:7`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-paws-al2:10`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-paws-al2:10`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-paws-al2:10`
    - `arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-paws-al2:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-paws-al2:9`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-paws-al2:10`
    - `arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-paws-al2:4`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-paws-al2:9`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-paws-al2:10`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-paws-al2:10`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-paws-al2:9`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-paws-al2:9`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-paws-al2:9`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws-al2:10`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-paws-al2:10`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-paws-al2:9`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-paws-al2:10`

## Pre-built Legacy Zip Archives for Amazon Linux 2 x86\_64

URLs of zip archives are here:

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime-al2.zip`

And Paws:

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws-al2.zip`

# SEE ALSO

- [AWS::Lambda::Bootstrap](https://metacpan.org/pod/AWS%3A%3ALambda%3A%3ABootstrap)
- [AWS::Lambda::Context](https://metacpan.org/pod/AWS%3A%3ALambda%3A%3AContext)
- [AWS::Lambda::PSGI](https://metacpan.org/pod/AWS%3A%3ALambda%3A%3APSGI)
- [Paws](https://metacpan.org/pod/Paws)
- [AWS::XRay](https://metacpan.org/pod/AWS%3A%3AXRay)

# LICENSE

The MIT License (MIT)

Copyright (C) ICHINOSE Shogo

# AUTHOR

ICHINOSE Shogo
