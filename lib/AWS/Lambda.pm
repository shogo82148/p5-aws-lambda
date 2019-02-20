package AWS::Lambda;
use 5.026000;
use strict;
use warnings;
use HTTP::Tiny;

our $VERSION = "0.0.1";

1;
__END__

=encoding utf-8

=head1 NAME

AWS::Lambda - It's Perl support for AWS Lambda Custom Runtime.

=head1 SYNOPSIS

Save the following Perl script as C<handler.pl>.

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
        --handler "handler.function" \
        --runtime provided \
        --role arn:aws:iam::xxxxxxxxxxxx:role/service-role/lambda-custom-runtime-perl-role \
        --layers "arn:aws:lambda:$REGION:445285296882:layer:perl-5-28-runtime:4"

=head1 DESCRIPTION

This package makes it easy to run AWS Lambda Functions written in Perl.

=head2 Use Prebuild Public Lambda Layer

=over

=item 1

Login to your AWS Account and go to the Lambda Console.

=item 2

Create a new function and give it a name and an IAM Role.

=item 3

For the "Runtime" selection, select B<Use custom runtime in function code or layer>.

=item 4

In the "Designer" section of your function dashboard, select the B<Layers> box.

=item 5

Scroll down to the "Referenced Layers" section and click B<Add a layer>.

=item 6

Select the B<Provide a layer version ARN> option, then copy/paste the Layer ARN for your region.

=item 7

Click the B<Add> button.

=item 8

Click B<Save> in the upper right.

=item 9

Upload your code and start using Perl in AWS Lambda!

=back

The Layer ARN list is here.

=over

=item Perl 5.28

=over

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-28-runtime:4>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-28-runtime:4>

=back

=item Perl 5.26

=over

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-26-runtime:4>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-26-runtime:4>

=back

=back

=head2 Use Prebuild Zip Archive

=over

=item 1

Login to your AWS Account and go to the Lambda Console.

=item 2

Create a new layer and give it a name.

=item 3

For the "Code entry type" selection, select B<Upload a file from Amazon S3>.

=item 4

In the "License" section, input L<https://github.com/shogo82148/p5-aws-lambda/blob/master/LICENSE>.

=item 5

Click B<Create> button.

=item 6

Use the layer created. For detail, see Use Prebuild Public Lambda Layer section.

=back

URLs for Zip archive are here.

C<https://s3-$REGION.amazonaws.com/shogo82148-lambda-perl-runtime-$REGION/perl-$VERSION-runtime.zip>

=head2 Run in Local using Docker

Here is prebuild docker image based on L<https://hub.docker.com/r/lambci/lambda/>

=over

=item L<https://hub.docker.com/r/shogo82148/p5-aws-lambda>

=back

    # Install the dependency.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-5.28 \
        cpanm --notest -L extlocal --installdeps .

    # run an event.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:5.28 \
        handler.handle '{"some":"event"}'

=head1 SEE ALSO

=over

=item L<AWS::Lambda::Bootstap>

=item L<AWS::Lambda::Context>

=item L<AWS::Lambda::PSGI>

=back

=head1 LICENSE

The MIT License (MIT)

Copyright (C) Ichinose Shogo.

=head1 AUTHOR

Ichinose Shogo E<lt>shogo82148@gmail.comE<gt>

=cut

