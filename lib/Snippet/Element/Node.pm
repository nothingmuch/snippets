#!/usr/bin/perl

package Snippet::Element::Node;
use Moose;

use Carp qw(croak);

use namespace::clean -except => 'meta';

with qw(Snippet::Element::Child);

has body => (
    is       => 'ro',
    isa      => 'XML::LibXML::Node',
    required => 1,
);

sub nodes { shift->body }

sub render { shift->body->toString }

sub length { 1 }

sub children {
    my $self = shift;
    map {
        Snippet::Element::Node->new(
            parent => $self,
            body   => $_,
        );
    } $self->body->getChildnodes;
}

sub _new_text_node {
    my ( $self, $text ) = @_;
    $self->body->ownerDocument->createTextNode($text);
}

sub _prepare_new_children {
    my ( $self, @children ) = @_;

    map { $self->_prepare_new_child($_) } @children;
}

sub _prepare_new_child {
    my ( $self, $child ) = @_;

    if ( ref $child ) {
        if ( blessed $child ) {
            if ( $child->does("Snippet::Element") ) {
                return $child->nodes;
            } else {
                return $child;
            }
        } else {
            croak "Content must be a string or an object";
        }
    } else {
        return $self->_new_text_node($child);
    }
}

sub content {
    my ( $self, @args ) = @_;

    croak "no content provided" unless @args;

    my @children = $self->_prepare_new_children(@args);

    $self->_replace_inner_node(@children);
}

sub html {
    my ( $self, $child ) = @_;

    my @nodes = $self->_parse_html_nodes($child);

    return $self->_replace_inner_node(@nodes);
}

sub text {
    my ( $self, $text ) = @_;

    croak "no text provided" unless defined $text;

    return $self->_replace_inner_node( $self->_new_text_node($text) );

    $self;
}


sub append {
    my ( $self, @children ) = @_;

    my @append = $self->_prepare_new_children(@children);

    my $body = $self->body;

    $body->addChild($_) for @append;

    $self;
}

sub prepend {
    my ( $self, @children ) = @_;

    my @prepend = reverse $self->_prepare_new_children(@children);

    my $body = $self->body;

    $body->prepend($_) for @prepend;

    $self;
}

sub attr {
    my ( $self, $name, @args ) = @_;

    my $body = $self->body;

    $body->setAttribute($name, $args[0]) if @args;

    $body->getAttribute($name);
}

sub clear {
    my $self = shift;

    my $body = $self->body;

    $body->removeChild($_) for $body->getChildNodes;

    $self;
}

sub _replace_inner_node {
    my ($self, @new) = @_;

    $self->clear;

    my $body = $self->body;
    $body->addChild($_) for @new;

    $self;
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

=pod

=head1 NAME

Snippet::Element::Node - 

=head1 SYNOPSIS

    use Snippet::Element::Node;

=head1 DESCRIPTION

=cut


