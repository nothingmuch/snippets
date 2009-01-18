package Snippet::Container;
use Moose::Role;

use Snippet::Meta::Attribute::Traits::Snippet;

use Carp qw(croak);

use namespace::clean -except => 'meta';

with qw(Snippet);

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
