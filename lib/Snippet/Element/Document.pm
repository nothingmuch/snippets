#!/usr/bin/perl

package Snippet::Element::Document;
use Moose;

use Carp qw(croak);

use namespace::clean -except => 'meta';

has body => (
    is       => 'ro',
    isa      => 'XML::LibXML::Document',
    coerce   => 1,
    required => 1,
);

has child_element => (
    isa => "Snippet::Element::Node",
    is  => "ro",
    lazy_build => 1,
    handles => [qw(
        render
        each
        length
        children
        clear
        append
        prepend
        content
        replace
        bind
        html
        text
        attr
        nodes
    )],
);

with qw(Snippet::Element);

sub _build_child_element {
    my $self = shift;

    Snippet::Element::Node->new( body => $self->body->documentElement, parent => $self );
}

sub has_parent { '' }
sub is_root { 1 }

sub root {
    my $self = shift;
    $self;
}

sub clone {
    my $self = shift;
    ( ref $self )->new( body => $self->clone_body );
}

sub remove {
    croak "Can't remove root element";
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

=pod

=head1 NAME

Snippet::Element::Document - 

=head1 SYNOPSIS

    use Snippet::Element::Document;

=head1 DESCRIPTION

=cut


