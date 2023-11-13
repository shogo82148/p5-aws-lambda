package AWS::Lambda::AL2;
use 5.026000;
use strict;
use warnings;

our $VERSION = "0.3.0";

# the context of Lambda Function
our $context;

our $LAYERS = {
    '5.38' => {
        'x86_64' => {
            'af-south-1' => {
                runtime_arn     => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ap-east-1' => {
                runtime_arn     => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ap-northeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ap-northeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ap-northeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ap-south-1' => {
                runtime_arn     => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ap-south-2' => {
                runtime_arn     => "arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:4",
                runtime_version => 4,
                paws_arn        => "arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-38-paws-al2-x86_64:3",
                paws_version    => 3,
            },
            'ap-southeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ap-southeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ap-southeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ap-southeast-4' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-38-runtime-al2-x86_64:4",
                runtime_version => 4,
                paws_arn        => "arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-38-paws-al2-x86_64:3",
                paws_version    => 3,
            },
            'ca-central-1' => {
                runtime_arn     => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'eu-central-1' => {
                runtime_arn     => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'eu-central-2' => {
                runtime_arn     => "arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:4",
                runtime_version => 4,
                paws_arn        => "arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-38-paws-al2-x86_64:3",
                paws_version    => 3,
            },
            'eu-north-1' => {
                runtime_arn     => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'eu-south-1' => {
                runtime_arn     => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'eu-south-2' => {
                runtime_arn     => "arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:4",
                runtime_version => 4,
                paws_arn        => "arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-38-paws-al2-x86_64:3",
                paws_version    => 3,
            },
            'eu-west-1' => {
                runtime_arn     => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'eu-west-2' => {
                runtime_arn     => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'eu-west-3' => {
                runtime_arn     => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'il-central-1' => {
                runtime_arn     => "arn:aws:lambda:il-central-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:4",
                runtime_version => 4,
                paws_arn        => "arn:aws:lambda:il-central-1:445285296882:layer:perl-5-38-paws-al2-x86_64:3",
                paws_version    => 3,
            },
            'me-central-1' => {
                runtime_arn     => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'me-south-1' => {
                runtime_arn     => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'sa-east-1' => {
                runtime_arn     => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'us-east-1' => {
                runtime_arn     => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'us-east-2' => {
                runtime_arn     => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'us-west-1' => {
                runtime_arn     => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'us-west-2' => {
                runtime_arn     => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-38-paws-al2-x86_64:4",
                paws_version    => 4,
            },
        },
        'arm64' => {
            'af-south-1' => {
                runtime_arn     => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'ap-east-1' => {
                runtime_arn     => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'ap-northeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'ap-northeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'ap-northeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'ap-south-1' => {
                runtime_arn     => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'ap-south-2' => {
                runtime_arn     => "arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-38-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-38-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'ap-southeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'ap-southeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'ap-southeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'ap-southeast-4' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-38-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-38-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'ca-central-1' => {
                runtime_arn     => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'eu-central-1' => {
                runtime_arn     => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'eu-central-2' => {
                runtime_arn     => "arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-38-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-38-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'eu-north-1' => {
                runtime_arn     => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'eu-south-1' => {
                runtime_arn     => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'eu-south-2' => {
                runtime_arn     => "arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-38-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-38-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'eu-west-1' => {
                runtime_arn     => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'eu-west-2' => {
                runtime_arn     => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'eu-west-3' => {
                runtime_arn     => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'il-central-1' => {
                runtime_arn     => "arn:aws:lambda:il-central-1:445285296882:layer:perl-5-38-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:il-central-1:445285296882:layer:perl-5-38-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'me-central-1' => {
                runtime_arn     => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-38-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-38-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'me-south-1' => {
                runtime_arn     => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'sa-east-1' => {
                runtime_arn     => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'us-east-1' => {
                runtime_arn     => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'us-east-2' => {
                runtime_arn     => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'us-west-1' => {
                runtime_arn     => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
            'us-west-2' => {
                runtime_arn     => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-38-paws-al2-arm64:4",
                paws_version    => 4,
            },
        },
    },
    '5.36' => {
        'x86_64' => {
            'af-south-1' => {
                runtime_arn     => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-east-1' => {
                runtime_arn     => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-northeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-northeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-northeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-south-1' => {
                runtime_arn     => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-south-2' => {
                runtime_arn     => "arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-36-paws-al2-x86_64:2",
                paws_version    => 2,
            },
            'ap-southeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-southeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-southeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-southeast-4' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-36-runtime-al2-x86_64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-36-paws-al2-x86_64:2",
                paws_version    => 2,
            },
            'ca-central-1' => {
                runtime_arn     => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'eu-central-1' => {
                runtime_arn     => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'eu-central-2' => {
                runtime_arn     => "arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-36-paws-al2-x86_64:2",
                paws_version    => 2,
            },
            'eu-north-1' => {
                runtime_arn     => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'eu-south-1' => {
                runtime_arn     => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'eu-south-2' => {
                runtime_arn     => "arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-36-paws-al2-x86_64:2",
                paws_version    => 2,
            },
            'eu-west-1' => {
                runtime_arn     => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'eu-west-2' => {
                runtime_arn     => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'eu-west-3' => {
                runtime_arn     => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'il-central-1' => {
                runtime_arn     => "arn:aws:lambda:il-central-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:il-central-1:445285296882:layer:perl-5-36-paws-al2-x86_64:2",
                paws_version    => 2,
            },
            'me-central-1' => {
                runtime_arn     => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'me-south-1' => {
                runtime_arn     => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'sa-east-1' => {
                runtime_arn     => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'us-east-1' => {
                runtime_arn     => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'us-east-2' => {
                runtime_arn     => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'us-west-1' => {
                runtime_arn     => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'us-west-2' => {
                runtime_arn     => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-36-paws-al2-x86_64:6",
                paws_version    => 6,
            },
        },
        'arm64' => {
            'af-south-1' => {
                runtime_arn     => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'ap-east-1' => {
                runtime_arn     => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'ap-northeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'ap-northeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'ap-northeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'ap-south-1' => {
                runtime_arn     => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'ap-south-2' => {
                runtime_arn     => "arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-36-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-36-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'ap-southeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'ap-southeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'ap-southeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'ap-southeast-4' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-36-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-36-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'ca-central-1' => {
                runtime_arn     => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'eu-central-1' => {
                runtime_arn     => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'eu-central-2' => {
                runtime_arn     => "arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-36-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-36-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'eu-north-1' => {
                runtime_arn     => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'eu-south-1' => {
                runtime_arn     => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'eu-south-2' => {
                runtime_arn     => "arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-36-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-36-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'eu-west-1' => {
                runtime_arn     => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'eu-west-2' => {
                runtime_arn     => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'eu-west-3' => {
                runtime_arn     => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'il-central-1' => {
                runtime_arn     => "arn:aws:lambda:il-central-1:445285296882:layer:perl-5-36-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:il-central-1:445285296882:layer:perl-5-36-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'me-central-1' => {
                runtime_arn     => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-36-runtime-al2-arm64:1",
                runtime_version => 1,
                paws_arn        => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-36-paws-al2-arm64:1",
                paws_version    => 1,
            },
            'me-south-1' => {
                runtime_arn     => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'sa-east-1' => {
                runtime_arn     => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'us-east-1' => {
                runtime_arn     => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'us-east-2' => {
                runtime_arn     => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'us-west-1' => {
                runtime_arn     => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
            'us-west-2' => {
                runtime_arn     => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8",
                runtime_version => 8,
                paws_arn        => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-36-paws-al2-arm64:7",
                paws_version    => 7,
            },
        },
    },
    '5.34' => {
        'x86_64' => {
            'af-south-1' => {
                runtime_arn     => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-east-1' => {
                runtime_arn     => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-northeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'ap-northeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-northeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'ap-south-1' => {
                runtime_arn     => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'ap-southeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'ap-southeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'ap-southeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-paws-al2-x86_64:4",
                paws_version    => 4,
            },
            'ca-central-1' => {
                runtime_arn     => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'eu-central-1' => {
                runtime_arn     => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'eu-north-1' => {
                runtime_arn     => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'eu-south-1' => {
                runtime_arn     => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'eu-west-1' => {
                runtime_arn     => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'eu-west-2' => {
                runtime_arn     => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'eu-west-3' => {
                runtime_arn     => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'me-central-1' => {
                runtime_arn     => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-34-paws-al2-x86_64:2",
                paws_version    => 2,
            },
            'me-south-1' => {
                runtime_arn     => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'sa-east-1' => {
                runtime_arn     => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'us-east-1' => {
                runtime_arn     => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'us-east-2' => {
                runtime_arn     => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'us-west-1' => {
                runtime_arn     => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-paws-al2-x86_64:6",
                paws_version    => 6,
            },
            'us-west-2' => {
                runtime_arn     => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-paws-al2-x86_64:7",
                paws_version    => 7,
            },
        },
        'arm64' => {
            'af-south-1' => {
                runtime_arn     => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ap-east-1' => {
                runtime_arn     => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ap-northeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'ap-northeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ap-northeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ap-south-1' => {
                runtime_arn     => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'ap-southeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'ap-southeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'ap-southeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ca-central-1' => {
                runtime_arn     => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'eu-central-1' => {
                runtime_arn     => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'eu-north-1' => {
                runtime_arn     => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'eu-south-1' => {
                runtime_arn     => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'eu-west-1' => {
                runtime_arn     => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'eu-west-2' => {
                runtime_arn     => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'eu-west-3' => {
                runtime_arn     => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'me-south-1' => {
                runtime_arn     => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'sa-east-1' => {
                runtime_arn     => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'us-east-1' => {
                runtime_arn     => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'us-east-2' => {
                runtime_arn     => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'us-west-1' => {
                runtime_arn     => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'us-west-2' => {
                runtime_arn     => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-paws-al2-arm64:6",
                paws_version    => 6,
            },
        },
    },
    '5.32' => {
        'x86_64' => {
            'af-south-1' => {
                runtime_arn     => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'ap-east-1' => {
                runtime_arn     => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'ap-northeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
            'ap-northeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'ap-northeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'ap-south-1' => {
                runtime_arn     => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
            'ap-southeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
            'ap-southeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
            'ap-southeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-runtime-al2-x86_64:5",
                runtime_version => 5,
                paws_arn        => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-paws-al2-x86_64:5",
                paws_version    => 5,
            },
            'ca-central-1' => {
                runtime_arn     => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'eu-central-1' => {
                runtime_arn     => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
            'eu-north-1' => {
                runtime_arn     => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'eu-south-1' => {
                runtime_arn     => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'eu-west-1' => {
                runtime_arn     => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
            'eu-west-2' => {
                runtime_arn     => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
            'eu-west-3' => {
                runtime_arn     => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'me-central-1' => {
                runtime_arn     => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:me-central-1:445285296882:layer:perl-5-32-paws-al2-x86_64:3",
                paws_version    => 3,
            },
            'me-south-1' => {
                runtime_arn     => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'sa-east-1' => {
                runtime_arn     => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'us-east-1' => {
                runtime_arn     => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
            'us-east-2' => {
                runtime_arn     => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
            'us-west-1' => {
                runtime_arn     => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-paws-al2-x86_64:7",
                paws_version    => 7,
            },
            'us-west-2' => {
                runtime_arn     => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:7",
                runtime_version => 7,
                paws_arn        => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-paws-al2-x86_64:8",
                paws_version    => 8,
            },
        },
        'arm64' => {
            'af-south-1' => {
                runtime_arn     => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ap-east-1' => {
                runtime_arn     => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ap-northeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'ap-northeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ap-northeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ap-south-1' => {
                runtime_arn     => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'ap-southeast-1' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'ap-southeast-2' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'ap-southeast-3' => {
                runtime_arn     => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'ca-central-1' => {
                runtime_arn     => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'eu-central-1' => {
                runtime_arn     => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'eu-north-1' => {
                runtime_arn     => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'eu-south-1' => {
                runtime_arn     => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'eu-west-1' => {
                runtime_arn     => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'eu-west-2' => {
                runtime_arn     => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'eu-west-3' => {
                runtime_arn     => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'me-south-1' => {
                runtime_arn     => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'sa-east-1' => {
                runtime_arn     => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'us-east-1' => {
                runtime_arn     => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'us-east-2' => {
                runtime_arn     => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
            'us-west-1' => {
                runtime_arn     => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3",
                runtime_version => 3,
                paws_arn        => "arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-paws-al2-arm64:2",
                paws_version    => 2,
            },
            'us-west-2' => {
                runtime_arn     => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime-al2-arm64:6",
                runtime_version => 6,
                paws_arn        => "arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-paws-al2-arm64:6",
                paws_version    => 6,
            },
        },
    },
};


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
        "5.38",      # Perl Version
        "us-east-1", # Region
        "x86_64",    # Architecture ("x86_64" or "arm64", optional, the default is "x86_64")
    );
    say $info->{runtime_arn};     # arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5
    say $info->{runtime_version}; # 5
    say $info->{paws_arn}         # arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-paws-al2-x86_64:4
    say $info->{paws_version}     # 4,

Or, you can use following one-liner.

    perl -MAWS::Lambda -e 'AWS::Lambda::print_runtime_arn("5.38", "us-east-1")'
    perl -MAWS::Lambda -e 'AWS::Lambda::print_paws_arn("5.38", "us-east-1")'

The list of all available layer ARN is here:

=over

=item Perl 5.38

=over

=item x86_64 architecture

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:4>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-38-runtime-al2-x86_64:4>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:4>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:4>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:il-central-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:4>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-38-runtime-al2-x86_64:5>

=back

=item arm64 architecture

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-38-runtime-al2-arm64:1>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-38-runtime-al2-arm64:1>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-38-runtime-al2-arm64:1>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-38-runtime-al2-arm64:1>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:il-central-1:445285296882:layer:perl-5-38-runtime-al2-arm64:1>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-38-runtime-al2-arm64:1>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-38-runtime-al2-arm64:5>

=back

=back

=item Perl 5.36

=over

=item x86_64 architecture

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:3>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-36-runtime-al2-x86_64:3>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:3>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:3>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:il-central-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:3>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-36-runtime-al2-x86_64:7>

=back

=item arm64 architecture

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:ap-south-2:445285296882:layer:perl-5-36-runtime-al2-arm64:1>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:ap-southeast-4:445285296882:layer:perl-5-36-runtime-al2-arm64:1>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:eu-central-2:445285296882:layer:perl-5-36-runtime-al2-arm64:1>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:eu-south-2:445285296882:layer:perl-5-36-runtime-al2-arm64:1>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:il-central-1:445285296882:layer:perl-5-36-runtime-al2-arm64:1>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-36-runtime-al2-arm64:1>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-36-runtime-al2-arm64:8>

=back

=back

=item Perl 5.34

=over

=item x86_64 architecture

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:3>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-runtime-al2-x86_64:7>

=back

=item arm64 architecture

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-runtime-al2-arm64:3>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-runtime-al2-arm64:6>

=back

=back

=item Perl 5.32

=over

=item x86_64 architecture

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-runtime-al2-x86_64:5>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:3>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime-al2-x86_64:6>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime-al2-x86_64:7>

=back

=item arm64 architecture

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime-al2-arm64:3>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime-al2-arm64:6>

=back

=back

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

=item Perl 5.38

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-38-runtime-al2:1>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-38-runtime-al2:1>

=back

=item Perl 5.36

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-36-runtime-al2:4>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-36-runtime-al2:4>

=back

=item Perl 5.34

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-runtime-al2:9>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-runtime-al2:9>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-runtime-al2:9>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-runtime-al2:9>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-runtime-al2:5>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-runtime-al2:9>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-runtime-al2:6>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-runtime-al2:9>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-runtime-al2:9>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-34-runtime-al2:3>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-runtime-al2:9>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-runtime-al2:9>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-runtime-al2:8>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-runtime-al2:9>

=back

=item Perl 5.32

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-runtime-al2:10>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-runtime-al2:10>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-runtime-al2:11>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-runtime-al2:10>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-runtime-al2:8>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-runtime-al2:11>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-runtime-al2:11>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-runtime-al2:11>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-runtime-al2:5>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-runtime-al2:10>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-runtime-al2:11>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-runtime-al2:6>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-runtime-al2:10>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-runtime-al2:11>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-runtime-al2:11>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-runtime-al2:10>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-32-runtime-al2:3>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-runtime-al2:10>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-runtime-al2:10>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-runtime-al2:11>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-runtime-al2:11>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-runtime-al2:10>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-runtime-al2:11>

=back

=back

And Paws layers:

=over

=item Perl 5.38

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-38-paws-al2:1>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-38-paws-al2:1>

=back

=item Perl 5.36

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-36-paws-al2:4>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-36-paws-al2:4>

=back

=item Perl 5.34

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-34-paws-al2:9>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-34-paws-al2:9>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-34-paws-al2:9>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-34-paws-al2:9>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-34-paws-al2:4>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-34-paws-al2:9>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-34-paws-al2:6>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-34-paws-al2:9>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-34-paws-al2:9>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-34-paws-al2:2>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-34-paws-al2:9>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-34-paws-al2:9>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-34-paws-al2:8>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-34-paws-al2:9>

=back

=item Perl 5.32

=over

=item C<arn:aws:lambda:af-south-1:445285296882:layer:perl-5-32-paws-al2:12>

=item C<arn:aws:lambda:ap-east-1:445285296882:layer:perl-5-32-paws-al2:12>

=item C<arn:aws:lambda:ap-northeast-1:445285296882:layer:perl-5-32-paws-al2:13>

=item C<arn:aws:lambda:ap-northeast-2:445285296882:layer:perl-5-32-paws-al2:12>

=item C<arn:aws:lambda:ap-northeast-3:445285296882:layer:perl-5-32-paws-al2:10>

=item C<arn:aws:lambda:ap-south-1:445285296882:layer:perl-5-32-paws-al2:13>

=item C<arn:aws:lambda:ap-southeast-1:445285296882:layer:perl-5-32-paws-al2:13>

=item C<arn:aws:lambda:ap-southeast-2:445285296882:layer:perl-5-32-paws-al2:13>

=item C<arn:aws:lambda:ap-southeast-3:445285296882:layer:perl-5-32-paws-al2:5>

=item C<arn:aws:lambda:ca-central-1:445285296882:layer:perl-5-32-paws-al2:12>

=item C<arn:aws:lambda:eu-central-1:445285296882:layer:perl-5-32-paws-al2:13>

=item C<arn:aws:lambda:eu-north-1:445285296882:layer:perl-5-32-paws-al2:7>

=item C<arn:aws:lambda:eu-south-1:445285296882:layer:perl-5-32-paws-al2:12>

=item C<arn:aws:lambda:eu-west-1:445285296882:layer:perl-5-32-paws-al2:13>

=item C<arn:aws:lambda:eu-west-2:445285296882:layer:perl-5-32-paws-al2:13>

=item C<arn:aws:lambda:eu-west-3:445285296882:layer:perl-5-32-paws-al2:12>

=item C<arn:aws:lambda:me-central-1:445285296882:layer:perl-5-32-paws-al2:3>

=item C<arn:aws:lambda:me-south-1:445285296882:layer:perl-5-32-paws-al2:12>

=item C<arn:aws:lambda:sa-east-1:445285296882:layer:perl-5-32-paws-al2:12>

=item C<arn:aws:lambda:us-east-1:445285296882:layer:perl-5-32-paws-al2:13>

=item C<arn:aws:lambda:us-east-2:445285296882:layer:perl-5-32-paws-al2:13>

=item C<arn:aws:lambda:us-west-1:445285296882:layer:perl-5-32-paws-al2:12>

=item C<arn:aws:lambda:us-west-2:445285296882:layer:perl-5-32-paws-al2:13>

=back

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
