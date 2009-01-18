package TestApp::Pages::Login;
use Moose;

extends 'Snippet::Page';

has 'message' => (
    traits   => [ 'Snippet::Meta::Attribute::Traits::Snippet' ],
    selector => '.message',
    is       => 'ro',
    isa      => 'Snippet::Notification',
    required => 1,
    bind     => "get_meesage",
);

has [qw(logged_in_message please_login_message login_error)] => (
    isa => "Snippet::Element",

sub get_meesage {
    my ( $self, %args ) = @_;
    
    if ( $args{is_authenticated} ) {
        return $self->logged_in_message;
    } elsif ( $args{login_error} ) {
        $self->login_error_message;
    } else {
        $self->please_login_message;
    }
}

has 'login_form' => (
    traits    => [ 'Snippet::Meta::Attribute::Traits::Snippet' ],
    selector  => '#login_form',
    is        => 'ro',
    isa       => 'TestApp::Snippet::LoginForm',
    required  => 1,
    unless    => "is_authenticated",
);

1;
