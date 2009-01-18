#!/usr/bin/perl

package Snippet::Notification;
use Moose;

use namespace::clean -except => 'meta';

with qw(Snippet);

sub process {
	my ( $self, %args ) = @_;

	my $body = $self->new_body;

	if ( my $msg = $args{content} ) {
		$body->content($msg);
	}

	return $body;
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
