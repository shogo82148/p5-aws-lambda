package AWS::Lambda::ResponseWriter;
use 5.026000;
use utf8;
use strict;
use warnings;
use HTTP::Tiny;

my %DefaultPort = (
    http => 80,
    https => 443,
);

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my %args;
    if (@_ == 1 && ref $_[0] eq 'HASH') {
        %args = %{$_[0]};
    } else {
        %args = @_;
    }

    my $http = $args{http} // HTTP::Tiny->new;
    my $response_url = $args{response_url} // die '$LAMBDA_TASK_ROOT is not found';
    my $content_type = $args{content_type} // 'application/json';
    my $self = bless +{
        response_url => $response_url,
        http         => $http,
        handle       => undef,
        closed       => 0,
    }, $class;
    return $self;
}

sub _request {
    my ($self, $content_type) = @_;
    my $response_url = $self->{response_url};
    my $http = $self->{http};
    my ($scheme, $host, $port, $path_query, $auth) = $http->_split_url($response_url);
    my $host_port = ($port == $DefaultPort{$scheme} ? $host : "$host:$port");
    my $request = {
        method    => "POST",
        scheme    => $scheme,
        host      => $host,
        port      => $port,
        host_port => $host_port,
        uri       => $path_query,
        headers   => {
            "host"              => $host_port,
            "content-type"      => $content_type,
            "transfer-encoding" => "chunked",
        },
        header_case => {
            "host"              => "Host",
            "content-type"      => "Content-Type",
            "transfer-encoding" => "Transfer-Encoding",
        },
    };
    my $peer = $host;

    # We remove the cached handle so it is not reused in the case of redirect.
    # reuse for the same scheme, host and port
    my $handle = delete $http->{handle};
    if ( $handle ) {
        unless ( $handle->can_reuse( $scheme, $host, $port, $peer ) ) {
            $handle->close;
            undef $handle;
        }
    }
    $handle ||= $http->_open_handle( $request, $scheme, $host, $port, $peer );
    $self->{handle} = $handle;

    $handle->write_request_header(@{$request}{qw/method uri headers header_case/});
}

sub _handle_response {
    my $self = shift;
    if (!$self->{closed}) {
        $self->close;
    }

    my $http = $self->{http};
    my $handle = $self->{handle};
    my $response;
    do { $response = $handle->read_response_header }
        until (substr($response->{status},0,1) ne '1');

    my $data_cb = $http->_prepare_data_cb($response, {});
    my $known_message_length = $handle->read_body($data_cb, $response);

    # Check if the HTTP request is using the keep-alive feature.
    if ( $http->{keep_alive}
        && $handle->connected
        && $known_message_length
        && $response->{protocol} eq 'HTTP/1.1'
        && ($response->{headers}{connection} || '') ne 'close'
    ) {
        # keep-alive
        $http->{handle} = $handle;
    }
    else {
        # close
        $handle->close;
    }
    $response->{success} = substr( $response->{status}, 0, 1 ) eq '2';
    $response->{url} = $self->{response_url};
    return $response;
}

sub write {
    my ($self, $data) = @_;
    if (!defined($data) || length($data) == 0) {
        return;
    }

    my $chunk  = sprintf '%X', length $data;
    $chunk .= "\x0D\x0A";
    $chunk .= $data;
    $chunk .= "\x0D\x0A";
    $self->{handle}->write($chunk);
}

sub close {
    my $self = shift;
    my $handle = $self->{handle};
    $handle->write("0\x0D\x0A\x0D\x0A");
    $self->{closed} = 1;
}

1;
