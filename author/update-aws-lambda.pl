#!/usr/bin/env perl

use 5.03000;
use strict;
use warnings;
use FindBin;
use Parallel::ForkManager;

my $regions = do {
    open my $fh, '<', "$FindBin::Bin/regions.txt" or die "$!";
    my @regions = sort { $a cmp $b } map { chomp; $_; } <$fh>;
    close($fh);
    \@regions;
};

my $versions = [
    "5.32",
    "5.30",
    "5.28",
    "5.26",
];
$versions = [sort {version->parse("v$b") <=> version->parse("v$a")} @$versions];

my $versions_al2 = [
    "5.32",
];
$versions_al2 = [sort {version->parse("v$b") <=> version->parse("v$a")} @$versions_al2];

# get the list of layers on Amazon Linux 1
my $layers = {};
my $pm = Parallel::ForkManager->new(10);
$pm->run_on_finish(sub {
    my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data) = @_;
    my ($version, $region, $arn) = @$data;
    $layers->{$version} //= {};
    $layers->{$version}{$region} = $arn;
});

for my $version (@$versions) {
    for my $region (@$regions) {
        say STDERR "loading $version in $region...";
        $pm->start("$version/$region") and next;

        my $runtime_stack = "lambda-@{[ $version =~ s/[.]/-/r ]}-runtime";
        chomp(my $runtime_arn = `aws --region $region cloudformation describe-stacks --stack-name $runtime_stack | jq -r .Stacks[0].Outputs[0].OutputValue`);
        my $paws_stack = "lambda-@{[ $version =~ s/[.]/-/r ]}-paws";
        chomp(my $paws_arn = `aws --region $region cloudformation describe-stacks --stack-name $paws_stack | jq -r .Stacks[0].Outputs[0].OutputValue`);

        $pm->finish(0, [$version, $region, {
            runtime_arn     => $runtime_arn,
            runtime_version => (split /:/, $runtime_arn)[-1],
            paws_arn        => $paws_arn,
            paws_version    => (split /:/, $paws_arn)[-1],
        }]);
    }
}
$pm->wait_all_children;

# get the list of layers on Amazon Linux 2
my $layers_al2 = {};
my $pm_al2 = Parallel::ForkManager->new(10);
$pm_al2->run_on_finish(sub {
    my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data) = @_;
    my ($version, $region, $arn) = @$data;
    $layers_al2->{$version} //= {};
    $layers_al2->{$version}{$region} = $arn;
});

for my $version (@$versions_al2) {
    for my $region (@$regions) {
        say STDERR "loading $version in $region...";
        $pm_al2->start("$version/$region") and next;

        my $runtime_stack = "lambda-@{[ $version =~ s/[.]/-/r ]}-runtime-al2";
        chomp(my $runtime_arn = `aws --region $region cloudformation describe-stacks --stack-name $runtime_stack | jq -r .Stacks[0].Outputs[0].OutputValue`);
        my $paws_stack = "lambda-@{[ $version =~ s/[.]/-/r ]}-paws-al2";
        chomp(my $paws_arn = `aws --region $region cloudformation describe-stacks --stack-name $paws_stack | jq -r .Stacks[0].Outputs[0].OutputValue`);

        $pm_al2->finish(0, [$version, $region, {
            runtime_arn     => $runtime_arn,
            runtime_version => (split /:/, $runtime_arn)[-1],
            paws_arn        => $paws_arn,
            paws_version    => (split /:/, $paws_arn)[-1],
        }]);
    }
}
$pm_al2->wait_all_children;

chomp(my $module_version = `cat $FindBin::Bin/../META.json | jq -r .version`);
my $latest_perl = $versions_al2->[0];
my $latest_perl_layer = $latest_perl =~ s/[.]/-/r;
my $latest_runtime_arn = $layers_al2->{$latest_perl}{'us-east-1'}{runtime_arn};
my $latest_runtime_version = $layers_al2->{$latest_perl}{'us-east-1'}{runtime_version};
my $latest_paws_arn = $layers_al2->{$latest_perl}{'us-east-1'}{paws_arn};
my $latest_paws_version = $layers_al2->{$latest_perl}{'us-east-1'}{paws_version};

open my $fh, '>', "$FindBin::Bin/../lib/AWS/Lambda.pm" or die "$!";

sub printfh($) {
    my $contents = shift;
    $contents =~ s/\@\@VERSION\@\@/$module_version/g;
    $contents =~ s/\@\@LATEST_PERL\@\@/$latest_perl/g;
    $contents =~ s/\@\@LATEST_PERL_LAYER\@\@/$latest_perl_layer/g;
    $contents =~ s/\@\@LATEST_RUNTIME_ARN\@\@/$latest_runtime_arn/g;
    $contents =~ s/\@\@LATEST_RUNTIME_VERSION\@\@/$latest_runtime_version/g;
    $contents =~ s/\@\@LATEST_PAWS_ARN\@\@/$latest_paws_arn/g;
    $contents =~ s/\@\@LATEST_PAWS_VERSION\@\@/$latest_paws_version/g;
    print $fh $contents;
}

printfh(<<'EOS');
package AWS::Lambda;
use 5.026000;
use strict;
use warnings;

our $VERSION = "@@VERSION@@";

# the context of Lambda Function
our $context;

EOS

print $fh "# This list is auto generated by authors/update-aws-lambda.pl; DO NOT EDIT\n";
print $fh "our \$LAYERS = {\n";
for my $version (@$versions) {
    print $fh "    '$version' => {\n";
    for my $region (@$regions) {
        print $fh <<EOS
        '$region' => {
            runtime_arn     => "$layers->{$version}{$region}{runtime_arn}",
            runtime_version => $layers->{$version}{$region}{runtime_version},
            paws_arn        => "$layers->{$version}{$region}{paws_arn}",
            paws_version    => $layers->{$version}{$region}{paws_version},
        },
EOS
    }
    print $fh "    },\n";
}
print $fh "};\n\n";

print $fh "our \$LAYERS_AL2 = {\n";
for my $version (@$versions_al2) {
    print $fh "    '$version' => {\n";
    for my $region (@$regions) {
        print $fh <<EOS
        '$region' => {
            runtime_arn     => "$layers_al2->{$version}{$region}{runtime_arn}",
            runtime_version => $layers_al2->{$version}{$region}{runtime_version},
            paws_arn        => "$layers_al2->{$version}{$region}{paws_arn}",
            paws_version    => $layers_al2->{$version}{$region}{paws_version},
        },
EOS
    }
    print $fh "    },\n";
}
print $fh "};\n\n";

printfh(<<'EOS');

sub get_layer_info {
    my ($version, $region) = @_;
    return $LAYERS->{$version}{$region};
}

sub print_runtime_arn {
    my ($version, $region) = @_;
    print $LAYERS->{$version}{$region}{runtime_arn};
}

sub print_paws_arn {
    my ($version, $region) = @_;
    print $LAYERS->{$version}{$region}{paws_arn};
}

sub get_layer_info_al2 {
    my ($version, $region) = @_;
    return $LAYERS_AL2->{$version}{$region};
}

sub print_runtime_arn_al2 {
    my ($version, $region) = @_;
    print $LAYERS_AL2->{$version}{$region}{runtime_arn};
}

sub print_paws_arn_al2 {
    my ($version, $region) = @_;
    print $LAYERS_AL2->{$version}{$region}{paws_arn};
}

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
        --handler "handler.handle" \
        --runtime provided.al2 \
        --role arn:aws:iam::xxxxxxxxxxxx:role/service-role/lambda-custom-runtime-perl-role \
        --layers "arn:aws:lambda:$REGION:445285296882:layer:perl-@@LATEST_PERL_LAYER@@-runtime-al2:@@LATEST_RUNTIME_VERSION@@"

=head1 DESCRIPTION

This package makes it easy to run AWS Lambda Functions written in Perl.

=head2 Use Prebuild Public Lambda Layer

=over

=item 1

Login to your AWS Account and go to the Lambda Console.

=item 2

Create a new function and give it a name and an IAM Role.

=item 3

For the "Runtime" selection, select B<Provide your own bootstrap on Amazon Linux 2>.

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

You can get the layer ARN in your script by using C<get_layer_info>.

    use AWS::Lambda;
    my $info = AWS::Lambda::get_layer_info_al2(
        "@@LATEST_PERL@@",      # Perl Version
        "us-east-1", # Region
    );
    say $info->{runtime_arn};     # @@LATEST_RUNTIME_ARN@@
    say $info->{runtime_version}; # @@LATEST_RUNTIME_VERSION@@
    say $info->{paws_arn}         # @@LATEST_PAWS_ARN@@
    say $info->{paws_version}     # @@LATEST_PAWS_VERSION@@,

Or, you can use following one-liner.

    perl -MAWS::Lambda -e 'AWS::Lambda::print_runtime_arn_al2("@@LATEST_PERL@@", "us-east-1")'
    perl -MAWS::Lambda -e 'AWS::Lambda::print_paws_arn_al2("@@LATEST_PERL@@", "us-east-1")'

The list of all available layer ARN is here:

=over

EOS

for my $version (@$versions_al2) {
    print $fh "=item Perl $version\n\n=over\n\n";
    for my $region (@$regions) {
        print $fh "=item C<$layers_al2->{$version}{$region}{runtime_arn}>\n\n";
    }
    print $fh "=back\n\n";
}

printfh(<<'EOS');
=back

=head2 Use Prebuilt Zip Archives

=over

=item 1

Login to your AWS Account and go to the Lambda Console.

=item 2

Create a new layer and give it a name.

=item 3

For the "Code entry type" selection, select B<Upload a file from Amazon S3>.

=item 4

In the "License" section, input L<https://github.com/shogo82148/p5-aws-lambda/blob/main/LICENSE>.

=item 5

Click B<Create> button.

=item 6

Use the layer created. For detail, see Use Prebuilt Public Lambda Layer section.

=back

URLs for Zip archives are here.

C<https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime-al2.zip>

=head2 Run in Local using Docker

L<https://hub.docker.com/r/shogo82148/p5-aws-lambda> is pre-built docker image based on L<https://hub.docker.com/r/lambci/lambda/>

    # Install the dependency.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-@@LATEST_PERL@@.al2 \
        cpanm --notest --local-lib extlocal --no-man-pages --installdeps .

    # run an event.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:@@LATEST_PERL@@.al2 \
        handler.handle '{"some":"event"}'

=head2 AWS XRay SUPPORT

L<AWS X-Ray|https://aws.amazon.com/xray/> is a service that collects data about requests that your application serves.
You can trace AWS Lambda requests and sends segment data with pre-install module L<AWS::XRay>.

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


=head1 Paws SUPPORT

If you want to call AWS API from your Lambda function,
you can use a pre-built Lambda Layer for L<Paws> - A Perl SDK for AWS (Amazon Web Services) APIs.

=head2 Use Prebuilt Public Lambda Layers

Add the perl-runtime layer and the perl-paws layer into your lambda function.

    aws --region "$REGION" --profile "$PROFILE" lambda create-function \
        --function-name "hello-perl" \
        --zip-file "fileb://handler.zip" \
        --handler "handler.handle" \
        --runtime provided.al2 \
        --role arn:aws:iam::xxxxxxxxxxxx:role/service-role/lambda-custom-runtime-perl-role \
        --layers \
            "arn:aws:lambda:$REGION:445285296882:layer:perl-@@LATEST_PERL_LAYER@@-runtime-al2:@@LATEST_RUNTIME_VERSION@@" \
            "arn:aws:lambda:$REGION:445285296882:layer:perl-@@LATEST_PERL_LAYER@@-paws-al2:@@LATEST_PAWS_VERSION@@"

Now, you can use L<Paws> to call AWS API from your Lambda function.

    use Paws;
    my $obj = Paws->service('...');
    my $res = $obj->MethodCall(Arg1 => $val1, Arg2 => $val2);
    print $res->AttributeFromResult;

The list of all available layer ARN is here:

=over

EOS

for my $version (@$versions_al2) {
    print $fh "=item Perl $version\n\n=over\n\n";
    for my $region (@$regions) {
        print $fh "=item C<$layers_al2->{$version}{$region}{paws_arn}>\n\n";
    }
    print $fh "=back\n\n";
}

printfh(<<'EOS');
=back

URLs for Zip archive are here.

C<https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws-al2.zip>

=head2 Run in Local using Docker

L<https://hub.docker.com/r/shogo82148/p5-aws-lambda> is pre-build docker image based on L<https://hub.docker.com/r/lambci/lambda/>

    # Install the dependency.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:build-@@LATEST_PERL@@-paws.al2 \
        cpanm --notest --local-lib extlocal --no-man-pages --installdeps .

    # run an event.
    docker run --rm -v $(PWD):/var/task shogo82148/p5-aws-lambda:@@LATEST_PERL@@-paws.al2 \
        handler.handle '{"some":"event"}'

=head1 CREATE MODULE LAYER

To create custom module layer such as the Paws Layer,
install the modules into C</opt/lib/perl5/site_perl> in the layer.

    # Create Some::Module Layer
    docker run --rm \
        -v $(PWD):/var/task \
        -v $(PATH_TO_LAYER_DIR)/lib/perl5/site_perl:/opt/lib/perl5/site_perl \
        shogo82148/p5-aws-lambda:build-@@LATEST_PERL@@.al2 \
        cpanm --notest --no-man-pages Some::Module
    cd $(PATH_TO_LAYER_DIR) && zip -9 -r $(PATH_TO_DIST)/some-module.zip .

=head1 LEGACY CUSTOM RUNTIME ON AMAZON LINUX

We also provide the layers for legacy custom runtime as known as "provided".

=head1 Prebuilt Public Lambda Layers

The list of all available layer ARN is here:

=over

EOS

for my $version (@$versions) {
    print $fh "=item Perl $version\n\n=over\n\n";
    for my $region (@$regions) {
        print $fh "=item C<$layers->{$version}{$region}{runtime_arn}>\n\n";
    }
    print $fh "=back\n\n";
}

printfh(<<'EOS');
=back

And Paws layers:

=over

EOS

for my $version (@$versions) {
    print $fh "=item Perl $version\n\n=over\n\n";
    for my $region (@$regions) {
        print $fh "=item C<$layers->{$version}{$region}{paws_arn}>\n\n";
    }
    print $fh "=back\n\n";
}

printfh(<<'EOS');
=back

=head2 Prebuilt Zip Archives

URLs of zip archives are here:

C<https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime.zip>

And Paws:

C<https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws.zip>

=head1 SEE ALSO

=over

=item L<AWS::Lambda::Bootstrap>

=item L<AWS::Lambda::Context>

=item L<AWS::Lambda::PSGI>

=item L<Paws>

=item L<AWS::XRay>

=back

=head1 LICENSE

The MIT License (MIT)

Copyright (C) Ichinose Shogo.

=head1 AUTHOR

Ichinose Shogo E<lt>shogo82148@gmail.comE<gt>

=cut
EOS

close($fh);
