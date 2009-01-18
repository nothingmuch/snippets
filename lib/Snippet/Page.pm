package Snippet::Page;
use Moose;

use Snippet::Meta::Attribute::Traits::Snippet;

use Carp qw(croak);

use namespace::clean -except => 'meta';

extends qw(Snippet);

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub _snippet_attributes {
	my $self = shift;

	grep { $_->does('Snippet::Meta::Attribute::Traits::Snippet') } 
		$self->meta->get_all_attributes
}

sub process {
    my ($self, %args) = @_;

	my $body = $self->new_body;

	my @attrs = $self->_snippet_attributes;

	if ( my $hide = $args{hide} ) {
		@attrs = grep { not $hide->{$_->name} } @attrs;
	}

	foreach my $attr ( @attrs ) {
		if ( my $content = eval { $attr->process($self, %args) } ) {
			my $selector = $attr->selector;

			my $container = $body->find($selector)
				or croak "No container found for $selector";

			$container->content($content);
		} elsif ( $@ ) {
			die "Error processing sub snippet " . $attr->name . ": $@";
		}
	}

	return $body;
}

1;

__END__

=pod

=head1 NAME

Snippet::Page - A Moosey solution to this problem

=head1 SYNOPSIS

  use Snippet::Page;

=head1 DESCRIPTION

=head1 METHODS 

=over 4

=item B<>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
