[![Actions Status](https://github.com/shogo82148/p5-aws-lambda/workflows/Test/badge.svg)](https://github.com/shogo82148/p5-aws-lambda/actions)
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
        --runtime provided.al2 \
        --role arn:aws:iam::xxxxxxxxxxxx:role/service-role/lambda-custom-runtime-perl-role \
        --layers "arn:aws:lambda:$REGION:445285296882:layer:perl-5-32-runtime-al2:1"

# DESCRIPTION

This package makes it easy to run AWS Lambda Functions written in Perl.

## Use Prebuild Public Lambda Layer

1. Login to your AWS Account and go to the Lambda Console.
2. Create a new function and give it a name and an IAM Role.
3. For the "Runtime" selection, select **Provide your own bootstrap on Amazon Linux 2**.
4. In the "Designer" section of your function dashboard, select the **Layers** box.
5. Scroll down to the "Referenced Layers" section and click **Add a layer**.
6. Select the **Provide a layer version ARN** option, then copy/paste the Layer ARN for your region.
7. Click the **Add** button.
8. Click **Save** in the upper right.
9. Upload your code and start using Perl in AWS Lambda!

You can get the layer ARN in your script by using `get_layer_info`.

    use AWS::Lambda;
    my $info = AWS::Lambda::get_layer_info_al2(
        "5.32",      # Perl Version
        "us-east-1", # Region
    );
    say $info->{runtime_arn};     # arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2:1
    say $info->{runtime_version}; # 1
    say $info->{paws_arn}         # arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws-al2:1
    say $info->{paws_version}     # 1,

Or, you can use following one-liner.

    perl -MAWS::Lambda -e 'AWS::Lambda::print_runtime_arn_al2("5.32", "us-east-1")'
    perl -MAWS::Lambda -e 'AWS::Lambda::print_paws_arn_al2("5.32", "us-east-1")'

The list of all available layer ARN is here:

- Perl 5.32
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime-al2:1`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime-al2:1`

## Use Prebuild Zip Archive

1. Login to your AWS Account and go to the Lambda Console.
2. Create a new layer and give it a name.
3. For the "Code entry type" selection, select **Upload a file from Amazon S3**.
4. In the "License" section, input [https://github.com/shogo82148/p5-aws-lambda/blob/master/LICENSE](https://github.com/shogo82148/p5-aws-lambda/blob/master/LICENSE).
5. Click **Create** button.
6. Use the layer created. For detail, see Use Prebuilt Public Lambda Layer section.

URLs for Zip archives are here.

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime-al2.zip`

## Run in Local using Docker

[https://hub.docker.com/r/shogo82148/p5-aws-lambda](https://hub.docker.com/r/shogo82148/p5-aws-lambda) is pre-built docker image based on [https://hub.docker.com/r/lambci/lambda/](https://hub.docker.com/r/lambci/lambda/)

    # Install the dependency.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.32.al2 \
        cpanm --notest --local-lib extlocal --no-man-pages --installdeps .

    # run an event.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.32.al2 \
        handler.handle '{"some":"event"}'

## AWS XRay SUPPORT

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
            "arn:aws:lambda:$REGION:445285296882:layer:perl-5-32-runtime-al2:1" \
            "arn:aws:lambda:$REGION:445285296882:layer:perl-5-32-paws-al2:1"

Now, you can use [Paws](https://metacpan.org/pod/Paws) to call AWS API from your Lambda function.

    use Paws;
    my $obj = Paws->service('...');
    my $res = $obj->MethodCall(Arg1 => $val1, Arg2 => $val2);
    print $res->AttributeFromResult;

The list of all available layer ARN is here:

- Perl 5.32
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-paws-al2:1`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-paws-al2:1`

URLs for Zip archive are here.

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws-al2.zip`

## Run in Local using Docker

[https://hub.docker.com/r/shogo82148/p5-aws-lambda](https://hub.docker.com/r/shogo82148/p5-aws-lambda) is pre-build docker image based on [https://hub.docker.com/r/lambci/lambda/](https://hub.docker.com/r/lambci/lambda/)

    # Install the dependency.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.32-paws.al2 \
        cpanm --notest --local-lib extlocal --no-man-pages --installdeps .

    # run an event.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.32-paws.al2 \
        handler.handle '{"some":"event"}'

# CREATE MODULE LAYER

To create custom module layer such as the Paws Layer,
install the modules into `/opt/lib/perl5/site_perl` in the layer.

    # Create Some::Module Layer
    docker run --rm \
        -v $(PWD):/var/task \
        -v $(PATH_TO_LAYER_DIR)/lib/perl5/site_perl:/opt/lib/perl5/site_perl \
        shogo82148/p5-aws-lambda:build-5.32.al2 \
        cpanm --notest --no-man-pages Some::Module
    cd $(PATH_TO_LAYER_DIR) && zip -9 -r $(PATH_TO_DIST)/some-module.zip .

# LEGACY CUSTOM RUNTIME ON AMAZON LINUX

We also provide the layers for legacy custom runtime as known as "provided".

# Prebuilt Public Lambda Layers

The list of all available layer ARN is here:

- Perl 5.32
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime:1`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime:1`
- Perl 5.30
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-30-runtime:2`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-30-runtime:2`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-30-runtime:7`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-30-runtime:9`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-30-runtime:9`
- Perl 5.28
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-28-runtime:2`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-28-runtime:8`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-28-runtime:2`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-28-runtime:6`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-28-runtime:15`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-28-runtime:15`
- Perl 5.26
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-26-runtime:2`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-26-runtime:9`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-26-runtime:16`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-26-runtime:16`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-26-runtime:16`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-26-runtime:16`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-26-runtime:16`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-26-runtime:16`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-26-runtime:16`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-26-runtime:2`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-26-runtime:16`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-26-runtime:15`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-26-runtime:15`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-26-runtime:6`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-26-runtime:15`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-26-runtime:15`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-26-runtime:15`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-26-runtime:15`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-26-runtime:15`

And Paws layers:

- Perl 5.32
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-paws:1`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-paws:1`
- Perl 5.30
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-30-paws:2`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-30-paws:5`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-30-paws:6`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-30-paws:6`
- Perl 5.28
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-28-paws:2`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-28-paws:4`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-28-paws:5`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-28-paws:5`
- Perl 5.26
    - `arn:aws:lambda:af-south-1:445285296882:layer:perl-5-26-paws:2`
    - `arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-26-paws:2`
    - `arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-26-paws:6`
    - `arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-26-paws:5`
    - `arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-26-paws:5`
    - `arn:aws:lambda:me-south-1:445285296882:layer:perl-5-26-paws:4`
    - `arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-26-paws:5`
    - `arn:aws:lambda:us-east-1:445285296882:layer:perl-5-26-paws:5`
    - `arn:aws:lambda:us-east-2:445285296882:layer:perl-5-26-paws:5`
    - `arn:aws:lambda:us-west-1:445285296882:layer:perl-5-26-paws:5`
    - `arn:aws:lambda:us-west-2:445285296882:layer:perl-5-26-paws:5`

## Prebuilt Zip Archives

URLs of zip archives are here:

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime.zip`

And Paws:

`https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws.zip`

# SEE ALSO

- [AWS::Lambda::Bootstrap](https://metacpan.org/pod/AWS%3A%3ALambda%3A%3ABootstrap)
- [AWS::Lambda::Context](https://metacpan.org/pod/AWS%3A%3ALambda%3A%3AContext)
- [AWS::Lambda::PSGI](https://metacpan.org/pod/AWS%3A%3ALambda%3A%3APSGI)
- [Paws](https://metacpan.org/pod/Paws)
- [AWS::XRay](https://metacpan.org/pod/AWS%3A%3AXRay)

# LICENSE

The MIT License (MIT)

Copyright (C) Ichinose Shogo.

# AUTHOR

Ichinose Shogo <shogo82148@gmail.com>
