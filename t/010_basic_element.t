#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Moose;
use Test::Exception;

BEGIN {
    use_ok('Snippet::Element');
}


my $e = Snippet::Element->new_from_string(
    q{<p>Hello <span class="place">???</span></p>}
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

my $span = Snippet::Element->new_from_string(
    q{<span class="moo" />}
);

$span->text("hello");

is( $span->render, q{<span class="moo">hello</span>}, "top level element" );

$span->html("<em>foo</em>");

is( $span->render, q{<span class="moo"><em>foo</em></span>}, "inner html" );

$span->find("em")->text("blah");

is( $span->render, q{<span class="moo"><em>blah</em></span>}, "find by element type" );

$span->find("em")->replace("instead");

is( $span->render, q{<span class="moo">instead</span>}, "replace" );

$span->content( Snippet::Element->new_from_string(q{<p id="elem">paragraph</p>}) );

is( $span->render, q{<span class="moo"><p id="elem">paragraph</p></span>}, "splice element" );

$span->find("#elem")->text("by id");

is( $span->render, q{<span class="moo"><p id="elem">by id</p></span>}, "find by id" );

$span->find("#elem")->remove;

is( $span->render, q{<span class="moo"/>}, "remove" );

$span->html(q{<ul><li id="item" class="item"/></ul>});

is( $span->render, q{<span class="moo"><ul><li id="item" class="item"/></ul></span>}, "html on root");

$span->find("#item")->bind(qw(foo bar gorch));

is( $span->render, q{<span class="moo"><ul><li class="item">foo</li><li class="item">bar</li><li class="item">gorch</li></ul></span>}, "bind");

$span->html(q{<select name="foo"><option/></select>});

$span->find("select option")->bind(
    { value => "1", content => "Foo" },
    { value => "2", content => "Bar" },
);

is( $span->render, q{<span class="moo"><select name="foo"><option value="1">Foo</option><option value="2">Bar</option></select></span>}, "bind hash" );
