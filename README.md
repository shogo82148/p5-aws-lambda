[![Build Status](https://travis-ci.com/shogo82148/p5-aws-lambda.svg?branch=master)](https://travis-ci.com/shogo82148/p5-aws-lambda)
# NAME

AWS::Lambda - It's Perl support for AWS Lambda Custom Runtime.

# SYNOPSIS

Save the following Perl script as `handler.pl`.

    sub handle {
        my ($payload, $context) = @_;
        return $payload;
    }

and then, zip the script.

    zip handler.zip handler.pl

Finally, create new function using awscli.

    aws --region "$REGION" --profile "$PROFILE" lambda create-function \
        --function-name "hello-perl" \
        --zip-file "fileb://handler.zip" \
        --handler "handler.handle" \
        --runtime provided \
        --role arn:aws:iam::xxxxxxxxxxxx:role/service-role/lambda-custom-runtime-perl-role \
        --layers "arn:aws:lambda:$REGION:445285296882:layer:perl-5-30-runtime:3"

# DESCRIPTION

This package makes it easy to run AWS Lambda Functions written in Perl.

## Use Prebuild Public Lambda Layer

1. Login to your AWS Account and go to the Lambda Console.
2. Create a new function and give it a name and an IAM Role.
3. For the "Runtime" selection, select **Use custom runtime in function code or layer**.
4. In the "Designer" section of your function dashboard, select the **Layers** box.
5. Scroll down to the "Referenced Layers" section and click **Add a layer**.
6. Select the **Provide a layer version ARN** option, then copy/paste the Layer ARN for your region.
7. Click the **Add** button.
8. Click **Save** in the upper right.
9. Upload your code and start using Perl in AWS Lambda!

The Layer ARN list is here.

- Perl 5.30
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-30-runtime:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-30-runtime:3`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-30-runtime:3`
- Perl 5.28
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-28-runtime:3`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-28-runtime:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-28-runtime:10`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-28-runtime:10`
- Perl 5.26
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-26-runtime:4`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-26-runtime:11`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-26-runtime:11`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-26-runtime:11`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-26-runtime:11`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-26-runtime:11`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-26-runtime:11`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-26-runtime:11`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-26-runtime:11`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-26-runtime:10`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-26-runtime:10`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-26-runtime:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-26-runtime:10`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-26-runtime:10`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-26-runtime:10`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-26-runtime:10`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-26-runtime:10`

## Use Prebuild Zip Archive

1. Login to your AWS Account and go to the Lambda Console.
2. Create a new layer and give it a name.
3. For the "Code entry type" selection, select **Upload a file from Amazon S3**.
4. In the "License" section, input [https://github.com/shogo82148/p5-aws-lambda/blob/master/LICENSE](https://github.com/shogo82148/p5-aws-lambda/blob/master/LICENSE).
5. Click **Create** button.
6. Use the layer created. For detail, see Use Prebuild Public Lambda Layer section.

URLs for Zip archive are here.

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime.zip`

## Run in Local using Docker

[https://hub.docker.com/r/shogo82148/p5-aws-lambda](https://hub.docker.com/r/shogo82148/p5-aws-lambda) is pre-build docker image based on [https://hub.docker.com/r/lambci/lambda/](https://hub.docker.com/r/lambci/lambda/)

    # Install the dependency.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.30 \
        cpanm --notest --local-lib extlocal --no-man-pages --installdeps .

    # run an event.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.30 \
        handler.handle '{"some":"event"}'

## AWS XRay SUPPORT

[AWS X-Ray](https://aws.amazon.com/xray/) is a service that collects data about requests that your application serves.
You can trace AWS Lambda requests and sends segment data with pre-install module [AWS::XRay](https://metacpan.org/pod/AWS::XRay).

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
you can use a pre-build Lambda Layer for [Paws](https://metacpan.org/pod/Paws) - A Perl SDK for AWS (Amazon Web Services) APIs.

## Use Prebuild Public Lambda Layer

Add the perl-runtime layer and the perl-paws layer into your lambda function.

    aws --region "$REGION" --profile "$PROFILE" lambda create-function \
        --function-name "hello-perl" \
        --zip-file "fileb://handler.zip" \
        --handler "handler.handle" \
        --runtime provided \
        --role arn:aws:iam::xxxxxxxxxxxx:role/service-role/lambda-custom-runtime-perl-role \
        --layers \
            "arn:aws:lambda:$REGION:445285296882:layer:perl-5-30-runtime:3" \
            "arn:aws:lambda:$REGION:445285296882:layer:perl-5-30-paws:2"

Now, you can use [Paws](https://metacpan.org/pod/Paws) to call AWS API from your Lambda function.

    use Paws;
    my $obj = Paws->service('...');
    my $res = $obj->MethodCall(Arg1 => $val1, Arg2 => $val2);
    print $res->AttributeFromResult;

The Layer ARN list is here.

- Perl 5.30
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-30-paws:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-30-paws:2`
- Perl 5.28
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-28-paws:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-28-paws:2`
- Perl 5.26
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-26-paws:3`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-26-paws:2`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-26-paws:2`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-26-paws:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-26-paws:2`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-26-paws:2`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-26-paws:2`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-26-paws:2`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-26-paws:2`

URLs for Zip archive are here.

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws.zip`

## Run in Local using Docker

[https://hub.docker.com/r/shogo82148/p5-aws-lambda](https://hub.docker.com/r/shogo82148/p5-aws-lambda) is pre-build docker image based on [https://hub.docker.com/r/lambci/lambda/](https://hub.docker.com/r/lambci/lambda/)

    # Install the dependency.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.30-paws \
        cpanm --notest --local-lib extlocal --no-man-pages --installdeps .

    # run an event.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.30-paws \
        handler.handle '{"some":"event"}'

# CREATE MODULE LAYER

To create custom module layer such as the Paws Layer,
install the modules into `/opt/lib/perl5/site_perl` in the layer.

    # Create Some::Module Layer
    docker run --rm \
        -v $(PWD):/var/task \
        -v $(PATH_TO_LAYER_DIR)/lib/perl5/site_perl:/opt/lib/perl5/site_perl \
        shogo82148/p5-aws-lambda:build-5.30 \
        cpanm --notest --no-man-pages Some::Module
    cd $(PATH_TO_LAYER_DIR) && zip -9 -r $(PATH_TO_DIST)/some-module.zip .

# SEE ALSO

- [AWS::Lambda::Bootstrap](https://metacpan.org/pod/AWS::Lambda::Bootstrap)
- [AWS::Lambda::Context](https://metacpan.org/pod/AWS::Lambda::Context)
- [AWS::Lambda::PSGI](https://metacpan.org/pod/AWS::Lambda::PSGI)
- [Paws](https://metacpan.org/pod/Paws)
- [AWS::XRay](https://metacpan.org/pod/AWS::XRay)

# LICENSE

The MIT License (MIT)

Copyright (C) Ichinose Shogo.

# AUTHOR

Ichinose Shogo <shogo82148@gmail.com>
