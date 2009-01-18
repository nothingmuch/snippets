#!/usr/bin/perl

package Snippet::Element::Child;
use Moose::Role;

use namespace::clean -except => 'meta';

with qw(Snippet::Element);

has parent => (
    is        => 'ro',
    isa       => 'Snippet::Element',
    predicate => "has_parent",
);

sub root { shift->parent->root }

sub is_root { ''}

sub each {
    my ($self, $f, @args) = @_;

    $_->$f(@args) for $self->children;

    $self;
}

sub clone {
    my $self = shift;
    ( ref $self )->new( body => $self->clone_body, parent => $self->parent ); # parent is meaningless for structure, it's navigational only
}

__PACKAGE__

__END__

=pod

=head1 NAME

Snippet::Element::Child - 

=head1 SYNOPSIS

    with qw(Snippet::Element::Child);

=head1 DESCRIPTION

=cut


