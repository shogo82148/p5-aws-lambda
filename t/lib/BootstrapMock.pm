package BootstrapMock;
use 5.026000;
use strict;
use warnings;
use AWS::Lambda::Bootstrap;

our @ISA = qw(AWS::Lambda::Bootstrap);

sub new {
    my $class = shift;
    my %args = @_;
    my $self  = $class->SUPER::new(%args);
    $self->{lambda_next}       = $args{lambda_next} // sub { die "unexpected call of lambda_next" };
    $self->{lambda_response}   = $args{lambda_response} // sub { die "unexpected call of lambda_response" };
    $self->{lambda_erorr}      = $args{lambda_erorr} // sub { die "unexpected call of lambda_erorr" };
    $self->{lambda_init_error} = $args{lambda_init_error} // sub { die "unexpected call of lambda_init_error" };
    return $self;
}

sub lambda_next {
    my $self = shift;
    return $self->{lambda_next}->($self, @_);
}

sub lambda_response {
    my $self = shift;
    return $self->{lambda_response}->($self, @_);
}

sub lambda_erorr {
    my $self = shift;
    return $self->{lambda_erorr}->($self, @_);
}

sub lambda_init_error {
    my $self = shift;
    return $self->{lambda_init_error}->($self, @_);
}

1;
