#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use FindBin;

use lib "$FindBin::Bin/lib";

use ok 'Snippet';
use ok 'Snippet::Element';
use ok 'Snippet::Page';
use ok 'Snippet::Notification';

use ok 'TestApp::Snippet::LoginForm';
use ok 'TestApp::Pages::Login';

my $html_dir = Path::Class::Dir->new($FindBin::Bin, qw[ lib html ]);

my $login = TestApp::Pages::Login->new(
    template   => $html_dir->file(qw[ testapp pages login.html ]),
    message    => Snippet::Notification->new(
        template => '<span class="notification"></span>',
    ),
    login_form => TestApp::Snippet::LoginForm->new(
        template => $html_dir->file(qw[ testapp snippet loginform.html ])
    ),
);

# this would be a method of a login page object
# page == Ernst::Web resource == a controller/action in MVC
# testapp::pages::login should be renamed to testapp::snippet::page::login
sub make_login {
    my ( %args ) = @_;

    my %process_args;

    # this is a model level behavior, it's in the Page object, not in the
    # snippet
    if ( my $u = $args{username} and my $p = $args{password} ) {
        if ( $u eq 'foo' && $p eq 'bar' ) {
            $process_args{is_authenticated} = 1;
        } else {
            $process_args{login_error} = 1;
        }
    }

    $login->process(%process_args);
}

{
    isa_ok($login, 'Snippet::Page');

    my $e;
    lives_ok {
        $e = make_login(),
    } '... process the page';

    is(
        $e->render,
        q{<html><head><title>Please Login</title></head><body><div class="message"><span class="notification">Please Login</span></div><div id="login_form"><form><label>Username</label><input type="text" name="username"/><label>Password</label><input type="text" name="password"/><hr/><input type="submit"/></form></div><div class="message"><span class="notification">Please Login</span></div></body></html>},
        '... got the right HTML'
    );
}

{
    isa_ok($login, 'Snippet::Page');

    my $e;
    lives_ok {
        $e = make_login(),
    } '... process the page';

    is(
        $e->render,
        q{<html><head><title>Please Login</title></head><body><div class="message"><span class="notification">Please Login</span></div><div id="login_form"><form><label>Username</label><input type="text" name="username"/><label>Password</label><input type="text" name="password"/><hr/><input type="submit"/></form></div><div class="message"><span class="notification">Please Login</span></div></body></html>},
        '... got the right HTML'
    );
}

{
    my $e;

    lives_ok {
        $e = make_login( username => 'foo', password => 'bar' );
    } '... process the page';

    is(
        $e->render,
        q{<html><head><title>Please Login</title></head><body><div class="message"><span class="notification">Thank You For Logging In</span></div><div id="login_form"><!-- login form goes here --></div><div class="message"><span class="notification">Thank You For Logging In</span></div></body></html>},
        '... got the right HTML'
    );
}

{
    my $e;

    lives_ok {
        $e = make_login( username => 'foo', password => 'blah' );
    } '... process the page';

    is(
        $e->render,
        q{<html><head><title>Please Login</title></head><body><div class="message"><span class="notification"><span class="error">Incorrect login</span></span></div><div id="login_form"><form><label>Username</label><input type="text" name="username"/><label>Password</label><input type="text" name="password"/><hr/><input type="submit"/></form></div><div class="message"><span class="notification"><span class="error">Incorrect login</span></span></div></body></html>},
        '... got the right HTML'
    );
}
