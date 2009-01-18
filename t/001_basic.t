#!/usr/bin/perl

use strict;
use warnings;

use Scalar::Util qw(refaddr);

use Test::More 'no_plan';
use Test::Exception;
use Test::Moose;

BEGIN {
    use_ok('Snippet');
}

{
    package My::Greeting::Snippet;
    use Moose;
    
    with 'Snippet::TransformBody';
    
    sub transform {
        my ( $self, $body, %args ) = @_;

        if ( my $thing = $args{greeting} ) {
            my $container = $body->find(".thing");
            $container->text($thing);
        }
    }
}

my $s = My::Greeting::Snippet->new(
    template => q{<p>Hello <span class="thing">???</span></p>}
);
isa_ok($s, 'My::Greeting::Snippet');
does_ok($s, 'Snippet');

{
    my $e;
    lives_ok {
        $e = $s->process;
    } '... processed snippet okay';

    isnt( refaddr($e->body), refaddr($s->template->body), "template cloned" );

    is($e->render, '<p>Hello <span class="thing">???</span></p>', '... rendered correctly');
}

{
    my $e;
    lives_ok {
        $e = $s->process( greeting => 'World' );
    } '... processed snippet okay';

    isnt( refaddr($e->body), refaddr($s->template->body), "template cloned" );

    is($e->render, '<p>Hello <span class="thing">World</span></p>', '... rendered correctly');

    is($s->template->render, '<p>Hello <span class="thing">???</span></p>', '... template not modified')
}
