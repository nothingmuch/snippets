#!/usr/bin/perl

package Snippet::Static;
use Moose::Role;

use namespace::clean -except => 'meta';

with qw(Snippet);

sub process { shift->new_body }

__PACKAGE__

__END__
