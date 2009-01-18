package Snippet::Meta::Attribute::Traits::Snippet;
use Moose::Role;

use Carp qw(croak);

use namespace::clean -except => 'meta';

sub Moose::Meta::Attribute::Custom::Trait::Snippet::Meta::Attribute::Traits::Snippet::register_implementation { __PACKAGE__ }

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'selector' => (
    is       => 'ro',
    isa      => 'Str',   
    required => 1,
);

# controls default visibility
has hidden => (
    isa => "Bool",
    is  => "ro",
);

has [qw(if unless)] => (
    isa => "Str",
    is  => "ro",
);

has condition => (
    isa => "CodeRef|Str",
    is  => "ro",
);

has content => (
    isa => "CodeRef|Str",
    is  => "ro",
);

has args => (
    isa => "CodeRef|Str",
    is  => "ro",
);

sub process {
    my ( $self, $object, @args ) = @_;

    if ( my $snippet = $self->get_snippet($object, @args) ) {
        my @process_args = $self->snippet_args($object, @args);

        if ( my $content = $snippet->process(@process_args) ) {
            return $content;
        } else {
            croak "Sub-snippet " . $self->name . " did not return a result";
        }
    } else {
        return;
    }
}

sub get_snippet {
    my ( $self, $object, %args ) = @_;

    my $snippet = $self->get_value($object) or return;

    my $hidden         = $self->hidden;
    my $cond_cb        = $self->condition;

    my $cond_arg;

    if ( defined(my $if = $self->if ) ) {
        $cond_arg = $args{$if} ? 1 : 0;
    }

    if ( defined(my $unless = $self->unless) ) {
        if ( exists $args{$unless} ) {
            $cond_arg = $args{$unless} ? 0 : 1;
        }
    }

    if ( $hidden ) {
        # if we're hidden by default, only display if one of the conditions is true
        if ( defined($cond_arg) && $cond_arg
                or
            $cond_cb && $object->$cond_cb(%args)
        ) {
            return $snippet;
        } else {
            return;
        }
    } else {
        # normal mode, hide if one of the conditions fails
        if ( defined($cond_arg) && !$cond_arg
                or
            $cond_cb && !$object->$cond_cb(%args)
        ) {
            return;
        } else {
            return $snippet;
        }
    }
}

sub snippet_args {
    my ( $self, $object, %args ) = @_;

    # top level args
    my @args = %args;

    # extract explicit nested args
    if ( my $sub_args = $args{args} ) {
        if ( my $my_args = $sub_args->{$self->name} ) {
            push @args, %$my_args;
        }
    }

    # call arg callback
    if ( my $args_cb = $self->args ) {
        push @args, $object->$args_cb(%args);
    }

    # call content callback
    if ( my $content_cb = $self->content ) {
        push @args, content => $object->$content_cb(%args);
    }

    push @args, parent => $object;

    return @args;
}

1;

__END__

=pod

=head1 NAME

Snippet::Meta::Attribute::Traits::Snippet - A Moosey solution to this problem

=head1 SYNOPSIS

  use Snippet::Meta::Attribute::Traits::Snippet;

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
