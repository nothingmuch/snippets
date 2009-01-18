#!/usr/bin/perl

package Snippet::TransformBody;
use Moose::Role;

use namespace::clean -except => 'meta';

with qw(Snippet);

requires "transform";

sub process {
    my ( $self, @args ) = @_;

    my $body = $self->new_body;

    $self->transform($body, @args);

    return $body;
}

__PACKAGE__

__END__
