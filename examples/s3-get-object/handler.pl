use utf8;
use warnings;
use strict;
use 5.30.0;
use Paws;
use Try::Tiny;
use URI::Escape;
use lib "$ENV{'LAMBDA_TASK_ROOT'}/extlocal/lib/perl5";

my $obj = Paws->service('S3', region => 'ap-northeast-1');

sub handle {
    my $payload = shift;
    # Get the object from the event and show its content type
    my $bucket = $payload->{Records}[0]{s3}{bucket}{name};
    my $key = uri_unescape($payload->{Records}[0]{s3}{object}{key} =~ s/\+/ /gr);
    my $resp = try {
        $obj->GetObject(
            Bucket => $bucket,
            Key    => $key,
        );
    } catch {
        print "$_\n";
        my $message = "Error getting object $key from bucket $bucket. Make sure they exist and your bucket is in the same region as this function.";
        print "$message\n";
        die $message;
    };

    printf "CONTENT TYPE: %s\n", $resp->ContentType;
    return $resp->ContentType;
}

1;
