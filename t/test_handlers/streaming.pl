use utf8;
use strict;
use warnings;
use AWS::Lambda;

# an example of echo using streaming response
# it is called from 14_streaming_response.t
sub handle {
    my ($payload, $context) = @_;
    die "payload is empty" unless $payload;
    die "context is empty" unless $context;
    die "AWS::Lambda::context is invalid" if $AWS::Lambda::context != $context;
    die "trace_id is empty" unless $ENV{_X_AMZN_TRACE_ID};
    return sub {
        my $responder = shift;
        my $writer = $responder->("application/json");
        $writer->write($payload);
        $writer->close;
    }
}

1;
