package TestApp::Pages::Login;
use Moose;

extends 'Snippet::Page';

has 'message' => (
    traits   => [ 'Snippet::Meta::Attribute::Traits::Snippet' ],
    selector => '.message',
    is       => 'ro',
    isa      => 'Snippet::Notification',
    required => 1,
	content  => sub {
		my ( $self, %args ) = @_;

		if ( $args{is_authenticated} ) {
			return "Thank You For Logging In";
		} elsif ( $args{login_error} ) {
			return Snippet::Element->new( body => q{<span class="error">Incorrect login</span>} );
		} else {
			return "Please Login";
		}
	}
);

has 'login_form' => (
    traits    => [ 'Snippet::Meta::Attribute::Traits::Snippet' ],
    selector  => '#login_form',
    is        => 'ro',
    isa       => 'TestApp::Snippet::LoginForm',
    required  => 1,
	unless    => "is_authenticated",
);

1;
