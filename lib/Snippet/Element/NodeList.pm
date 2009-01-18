#!/usr/bin/perl

package Snippet::Element::NodeList;
use Moose;

use Carp qw(croak);

use namespace::clean -except => 'meta';

with qw(Snippet::Element::Child);

has body => (
    is       => 'ro',
    isa      => 'XML::LibXML::NodeList',
    required => 1,
);

sub nodes { shift->body->get_nodelist }

sub length { shift->body->size }

sub children { @{ shift->_children } }

has _children => (
    isa => "ArrayRef[Snippet::Element::Node]",
    is  => "ro",
    lazy_build => 1,
);

sub _build__children {
    my $self = shift;

    return [
        map {
            Snippet::Element::Node->new(
                body => $_,
                parent => $self
            );
        } $self->nodes
    ];
}

sub _clone_args {
    my ( $self, @args ) = @_;

    my @clones;

    foreach my $arg ( @args ) {
        if ( ref $arg ) {
            push @clones, $arg->cloneNode(1);
        } else {
            push @clones, $arg;
        }
    }

    return @clones;
}

BEGIN {
    # FIXME iterate required methods?
    foreach my $method (qw(content append prepend text html clear)) {
        eval qq{
            sub $method {
                my ( \$self, \@args ) = \@_;

                foreach my \$child ( \$self->children ) {
                    \$child->$method( \$self->_clone_args(\@args) );
                }

                \$self;
            }
        };

        die $@ if $@;
    }
}

sub render {
    my $self = shift;

    join "", map { $_->toString } $self->nodes;
}

sub attr {
    croak "Cannot call attr() on a node_list";
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

=pod

=head1 NAME

Snippet::Element::NodeList - 

=head1 SYNOPSIS

    use Snippet::Element::NodeList;

=head1 DESCRIPTION

=cut


