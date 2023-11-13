#!/usr/bin/env perl

use v5.36;
use FindBin;
use Parallel::ForkManager;
use Capture::Tiny ('capture');

my $archs = ['x86_64', 'arm64'];
my $regions = +{ map {
    my $arch = $_;
    open my $fh, '<', "$FindBin::Bin/regions-$arch.txt" or die "$!";
    my @regions = sort { $a cmp $b } map { chomp; $_; } <$fh>;
    close($fh);
    ($arch => \@regions);
} @$archs };

my $versions_al2 = [
    "5.38",
    "5.36",
    "5.34",
    "5.32",
];
$versions_al2 = [sort {version->parse("v$b") <=> version->parse("v$a")} @$versions_al2];

# get the list of layers on Amazon Linux 2
my $layers_al2_x86_64 = {};
my $pm_al2_x86_64 = Parallel::ForkManager->new(10);
$pm_al2_x86_64->run_on_finish(sub {
    my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data) = @_;
    return unless $data;
    my ($version, $region, $arn) = @$data;
    return unless $version && $region && $arn;

    $layers_al2_x86_64->{$version} //= {};
    $layers_al2_x86_64->{$version}{$region} = $arn;
});

for my $version (@$versions_al2) {
    for my $region (@{$regions->{x86_64}}) {
        say STDERR "loading $version in $region...";
        $pm_al2_x86_64->start("$version/$region") and next;

        my $runtime_stack = "lambda-$version-runtime-al2" =~ s/[._]/-/gr;
        my $paws_stack = "lambda-$version-paws-al2" =~ s/[._]/-/gr;
        my ($stdout, $stderr, $exit);

        ($stdout, $stderr, $exit) = capture {
            system("aws --region $region cloudformation describe-stacks --output json --stack-name $runtime_stack | jq -r .Stacks[0].Outputs[0].OutputValue");
        };
        if ($exit != 0) {
            if ($stderr =~ /ValidationError/) {
                # the stack doesn't exist; skip it.
                $pm_al2_x86_64->finish;
                next;
            }
            die "failed to execute aws cli";
        }
        my $runtime_arn = $stdout;

        ($stdout, $stderr, $exit) = capture {
            system("aws --region $region cloudformation describe-stacks --output json --stack-name $paws_stack | jq -r .Stacks[0].Outputs[0].OutputValue");
        };
        if ($exit != 0) {
            if ($stderr =~ /ValidationError/) {
                # the stack doesn't exist; skip it.
                $pm_al2_x86_64->finish;
                next;
            }
            die "failed to execute aws cli";
        }
        my $paws_arn = $stdout;
 
        chomp($runtime_arn);
        chomp($paws_arn);
        $pm_al2_x86_64->finish(0, [$version, $region, {
            runtime_arn     => $runtime_arn,
            runtime_version => (split /:/, $runtime_arn)[-1],
            paws_arn        => $paws_arn,
            paws_version    => (split /:/, $paws_arn)[-1],
        }]);
    }
}
$pm_al2_x86_64->wait_all_children;

# get the list of layers on Amazon Linux 2 for each arch
my $layers_al2 = {};
my $pm_al2 = Parallel::ForkManager->new(10);
$pm_al2->run_on_finish(sub {
    my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data) = @_;
    return unless $data;
    my ($version, $region, $arch, $arn) = @$data;
    return unless $version && $region && $arch && $arn;
    $layers_al2->{$version} //= {};
    $layers_al2->{$version}{$region} //= {};
    $layers_al2->{$version}{$region}{$arch} = $arn;
});

for my $version (@$versions_al2) {
    for my $arch (@$archs) {
        for my $region (@{$regions->{$arch}}) {
            say STDERR "loading $version in $region...";
            $pm_al2->start("$version/$region/$arch") and next;

            my $runtime_stack = "lambda-$version-runtime-al2-$arch" =~ s/[._]/-/gr;
            my $paws_stack = "lambda-$version-paws-al2-$arch" =~ s/[._]/-/gr;
            my ($stdout, $stderr, $exit);

            ($stdout, $stderr, $exit) = capture {
                system("aws --region $region cloudformation describe-stacks --output json --stack-name $runtime_stack | jq -r .Stacks[0].Outputs[0].OutputValue");
            };
            if ($exit != 0) {
                if ($stderr =~ /ValidationError/) {
                    # the stack doesn't exist; skip it.
                    $pm_al2->finish;
                    next;
                }
                die "failed to execute aws cli";
            }
            my $runtime_arn = $stdout;

            ($stdout, $stderr, $exit) = capture {
                system("aws --region $region cloudformation describe-stacks --output json --stack-name $paws_stack | jq -r .Stacks[0].Outputs[0].OutputValue");
            };
            if ($exit != 0) {
                if ($stderr =~ /ValidationError/) {
                    # the stack doesn't exist; skip it.
                    $pm_al2->finish;
                    next;
                }
                die "failed to execute aws cli";
            }
            my $paws_arn = $stdout;

            chomp($runtime_arn);
            chomp($paws_arn);
            $pm_al2->finish(0, [$version, $region, $arch, {
                runtime_arn     => $runtime_arn,
                runtime_version => (split /:/, $runtime_arn)[-1],
                paws_arn        => $paws_arn,
                paws_version    => (split /:/, $paws_arn)[-1],
            }]);
        }
    }
}
$pm_al2->wait_all_children;

chomp(my $module_version = `cat $FindBin::Bin/../META.json | jq -r .version`);
my $latest_perl = $versions_al2->[0];
my $latest_perl_layer = $latest_perl =~ s/[.]/-/r;
my $latest_runtime_arn = $layers_al2->{$latest_perl}{'us-east-1'}{x86_64}{runtime_arn};
my $latest_runtime_version = $layers_al2->{$latest_perl}{'us-east-1'}{x86_64}{runtime_version};
my $latest_paws_arn = $layers_al2->{$latest_perl}{'us-east-1'}{x86_64}{paws_arn};
my $latest_paws_version = $layers_al2->{$latest_perl}{'us-east-1'}{x86_64}{paws_version};

open my $fh, '>', "$FindBin::Bin/../lib/AWS/Lambda/AL2.pm" or die "$!";

sub printfh :prototype($) {
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
package AWS::Lambda::AL2;
use 5.026000;
use strict;
use warnings;

our $VERSION = "@@VERSION@@";

EOS

print $fh "# This list is auto generated by authors/update-aws-lambda-al2.pl; DO NOT EDIT\n";
print $fh "our \$LAYERS = {\n";
for my $version (@$versions_al2) {
    print $fh "    '$version' => {\n";
    for my $arch (@$archs) {
        print $fh "        '$arch' => {\n";
        for my $region (@{$regions->{$arch}}) {
            next unless $layers_al2->{$version}{$region}{$arch}{runtime_arn};
            print $fh <<EOS
            '$region' => {
                runtime_arn     => "$layers_al2->{$version}{$region}{$arch}{runtime_arn}",
                runtime_version => $layers_al2->{$version}{$region}{$arch}{runtime_version},
                paws_arn        => "$layers_al2->{$version}{$region}{$arch}{paws_arn}",
                paws_version    => $layers_al2->{$version}{$region}{$arch}{paws_version},
            },
EOS
        }
        print $fh "        },\n";
    }
    print $fh "    },\n";
}
print $fh "};\n\n";

printfh(<<'EOS');

sub get_layer_info {
    my ($version, $region, $arch) = @_;
    $arch //= 'x86_64';
    return $LAYERS->{$version}{$arch}{$region};
}

sub print_runtime_arn {
    my ($version, $region, $arch) = @_;
    $arch //= 'x86_64';
    print $LAYERS->{$version}{$arch}{$region}{runtime_arn};
}

sub print_paws_arn {
    my ($version, $region, $arch) = @_;
    $arch //= 'x86_64';
    print $LAYERS->{$version}{$arch}{$region}{paws_arn};
}

1;
__END__

=encoding utf-8

=head1 NAME

AWS::Lambda::AL2 - AWS Lambda Custom Runtimes based on Amazon Linux 2

=head1 SYNOPSIS

You can get the layer ARN in your script by using C<get_layer_info>.

    use AWS::Lambda::AL2;
    my $info = AWS::Lambda::get_layer_info(
        "@@LATEST_PERL@@",      # Perl Version
        "us-east-1", # Region
        "x86_64",    # Architecture ("x86_64" or "arm64", optional, the default is "x86_64")
    );
    say $info->{runtime_arn};     # @@LATEST_RUNTIME_ARN@@
    say $info->{runtime_version}; # @@LATEST_RUNTIME_VERSION@@
    say $info->{paws_arn}         # @@LATEST_PAWS_ARN@@
    say $info->{paws_version}     # @@LATEST_PAWS_VERSION@@,

Or, you can use following one-liner.

    perl -MAWS::Lambda -e 'AWS::Lambda::print_runtime_arn("@@LATEST_PERL@@", "us-east-1")'
    perl -MAWS::Lambda -e 'AWS::Lambda::print_paws_arn("@@LATEST_PERL@@", "us-east-1")'

The list of all available layer ARN is here:

=over

EOS

for my $version (@$versions_al2) {
    print $fh "=item Perl $version\n\n=over\n\n";
    for my $arch(@$archs) {
        print $fh "=item $arch architecture\n\n=over\n\n";
        for my $region (@{$regions->{$arch}}) {
            next unless $layers_al2->{$version}{$region}{$arch}{runtime_arn};
            print $fh "=item C<$layers_al2->{$version}{$region}{$arch}{runtime_arn}>\n\n";
        }
        print $fh "=back\n\n";
    }
    print $fh "=back\n\n";
}

printfh(<<'EOS');
=back

=head2 Use Pre-built Zip Archives

URLs for Zip archives are:

C<https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime-al2-$ARCHITECTURE.zip>

And Paws:

C<https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws-al2-$ARCHITECTURE.zip>

=head2 Pre-installed modules

The following modules are pre-installed for convenience.

=over

=item L<AWS::Lambda>

=item L<AWS::XRay>

=item L<JSON>

=item L<Cpanel::JSON::XS>

=item L<JSON::MaybeXS>

=item L<YAML>

=item L<YAML::Tiny>

=item L<YAML::XS>

=item L<Net::SSLeay>

=item L<IO::Socket::SSL>

=item L<Mozilla::CA>

=back

L<Paws> is optional. See the "Paws SUPPORT" section.

=head1 LEGACY CUSTOM RUNTIME ON AMAZON LINUX 2

Previously, we provided the layers that named without CPU architectures.
These layers are compatible with x86_64 and only for backward compatibility.
We recommend to specify the CPU architecture.
These layers are NO LONGER MAINTAINED and WILL NOT RECEIVE ANY UPDATES.

=head2 Pre-built Legacy Public Lambda Layers for Amazon Linux 2

The list of all available layer ARN is:

=over

EOS

for my $version (@$versions_al2) {
    print $fh "=item Perl $version\n\n=over\n\n";
    for my $region (@{$regions->{x86_64}}) {
        next unless $layers_al2_x86_64->{$version}{$region}{runtime_arn};
        print $fh "=item C<$layers_al2_x86_64->{$version}{$region}{runtime_arn}>\n\n";
    }
    print $fh "=back\n\n";
}

printfh(<<'EOS');
=back

And Paws layers:

=over

EOS

for my $version (@$versions_al2) {
    print $fh "=item Perl $version\n\n=over\n\n";
    for my $region (@{$regions->{x86_64}}) {
        next unless $layers_al2_x86_64->{$version}{$region}{paws_arn};
        print $fh "=item C<$layers_al2_x86_64->{$version}{$region}{paws_arn}>\n\n";
    }
    print $fh "=back\n\n";
}

printfh(<<'EOS');
=back

=head2 Pre-built Legacy Zip Archives for Amazon Linux 2 x86_64

URLs of zip archives are here:

C<https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-runtime-al2.zip>

And Paws:

C<https://shogo82148-lambda-perl-runtime-$REGION.s3.amazonaws.com/perl-$VERSION-paws-al2.zip>

=head1 SEE ALSO

=over

=item L<AWS::Lambda>

=item L<AWS::Lambda::Bootstrap>

=item L<AWS::Lambda::Context>

=item L<AWS::Lambda::PSGI>

=item L<Paws>

=item L<AWS::XRay>

=back

=head1 LICENSE

The MIT License (MIT)

Copyright (C) ICHINOSE Shogo

=head1 AUTHOR

ICHINOSE Shogo

=cut
EOS

close($fh);
