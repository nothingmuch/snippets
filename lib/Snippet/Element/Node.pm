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

sub bind {
    my ( $self, @values ) = @_;

    my $binding = @values == 1 ? $values[0] : \@values;

    if ( ref $binding eq 'ARRAY' ) {
        my @bound = map { $self->clone->clear_attr('id')->bind($_) } @$binding;
        return $self->replace(@bound);
    } elsif ( ref $binding eq 'HASH' ) {
        my %attrs = %$binding;
        my $data = delete $attrs{content};
        return $self->set_attr(%attrs)->bind($data);
    } else {
        return $self->content($self->_clone_args($binding));
    }
}


sub replace {
    my ( $self, @args ) = @_;

    croak "no content provided" unless @args;

    my @children = $self->_prepare_new_children(@args);

    my $body = $self->body;
    my $parent = $body->parentNode;

    $parent->insertBefore($_, $body) for @children;
    $parent->removeChild($body);

    $self;
}

sub content {
    my ( $self, @args ) = @_;

    croak "no content provided" unless @args;

    my @children = $self->_prepare_new_children(@args);

    $self->_replace_inner_node(@children);
}

sub html {
    my ( $self, $html ) = @_;

    croak "no html provided" unless defined $html;

    my @nodes = $self->_parse_html_nodes($html);

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

sub set_attr {
    my ( $self, %pairs ) = @_;

    my @clear;

    foreach my $key ( keys %pairs ) {
        if ( defined( my $value = $pairs{$key} ) ) {
            $self->body->setAttribute($key, $value);
        } else {
            push @clear, $key;
        }
    }

    $self->clear_attr(@clear);

    $self;
}

sub clear_attr {
    my ( $self, @attrs ) = @_;

    my $body = $self->body;

    $body->removeAttribute($_) for @attrs;

    $self;
}

sub attr {
    my ( $self, $name, @args ) = @_;

    if ( @args ) {
        $self->set_attr($name, @args);
    }

    $self->body->getAttribute($name);
}

sub remove {
    my ( $self, @args ) = @_;

    my $body = $self->body;

    $body->parentNode->removeChild($body);

    $self;
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


