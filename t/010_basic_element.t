#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Snippet::Element');
}


my $e = Snippet::Element::Document->new(
    body => q{<p>Hello <span class="place">???</span></p>}
);

does_ok($e, 'Snippet::Element');

ok(!$e->has_parent, '... no parent element');
ok($e->is_root, '... is root element');

is($e->length, 1, '... is a single element');

is($e->render, q{<p>Hello <span class="place">???</span></p>}, '... got the right HTML');

ok(! defined $e->find('.thing'), '... found nothing');

my $sub_e = $e->find('.place');
does_ok($sub_e, 'Snippet::Element');

is($sub_e->length, 1, '... is a single element');

is($sub_e->attr('class'), 'place', '... got the value of the class attribute');
ok(! defined $sub_e->attr('id'), '... got no value for the id attribute');

is($sub_e->render, q{<span class="place">???</span>}, '... got the right HTML');

lives_ok {
    $sub_e->attr('class' => 'thing');
} '... set the attribute correctly';

is($sub_e->attr('class'), 'thing', '... got the value of the class attribute');

is($sub_e->render, q{<span class="thing">???</span>}, '... got the right HTML');

ok($sub_e->has_parent, '... has parent element');
is($sub_e->parent, $e, '... the parent is attached');

ok(!$sub_e->is_root, '... is not a root element');

lives_ok {
    $sub_e->html('<i>World</i>');
} '... replace_html successfully';

is($sub_e->render, q{<span class="thing"><i>World</i></span>}, '... got the right HTML');
is($e->render, q{<p>Hello <span class="thing"><i>World</i></span></p>}, '... got the right HTML');


lives_ok {
    $sub_e->text('Moose');
} '... replace_html successfully';

is($sub_e->render, q{<span class="thing">Moose</span>}, '... got the right HTML');
is($e->render, q{<p>Hello <span class="thing">Moose</span></p>}, '... got the right HTML');

my $c = $e->clone;

$c->find(".thing")->text("lalala");

is($c->render, q{<p>Hello <span class="thing">lalala</span></p>}, '... got the right HTML');

is($sub_e->render, q{<span class="thing">Moose</span>}, '... got the right HTML');
is($e->render, q{<p>Hello <span class="thing">Moose</span></p>}, '... got the right HTML');

my $span = Snippet::Element::Document->new(
    body => q{<span class="moo" />}
);

$span->text("hello");

is( $span->render, q{<span class="moo">hello</span>} );
