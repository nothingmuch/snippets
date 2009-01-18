package Snippet::Element;
use Moose::Role;
use Moose::Util::TypeConstraints;

# this is where is all happens
# some of it ain't pretty either
# but it gives us a pretty front
# end, which right now is all I 
# care about (sorry jrockway)

use Carp qw(croak);

# NOTE:
# There is no reason why we cant
# use another XML parser here either
# they would simple need to reimplement
# about 80% of this class, but it is
# possible. (think: Drivers)
# - SL

use XML::LibXML;
use HTML::Selector::XPath;
use MooseX::Types::Path::Class qw(File);

use namespace::clean -except => 'meta';

use overload '""' => sub { overload::StrVal($_[0]) . "[" . $_[0]->body . "]" };

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# NOTE:
# this should likely be injected
# via Bread::Board I think, but 
# we really only need it very 
# occasionally, so I dunno.
# - SL
my $PARSER = XML::LibXML->new;
$PARSER->no_network(1);
$PARSER->keep_blanks(0); # << on the fly whitespace "compression"

class_type 'XML::LibXML::Node';
class_type 'XML::LibXML::NodeList';
class_type 'XML::LibXML::Document';

coerce 'XML::LibXML::Document'
    => from Str => via { $PARSER->parse_string($_) },
    => from File,  via { $PARSER->parse_file($_->stringify) };

# I am coerce-able
coerce 'Snippet::Element'
    => from Str => via { Snippet::Element::Document->new(body => $_) },
    => from File,  via { Snippet::Element::Document->new(body => $_) };

requires qw(
    render

    clear
    append
    prepend
    content
    text
    html
    attr

    children
    each

    length

    is_root
    root

    nodes
);

sub cloneNode { shift->clone }

sub clone_body { shift->body->cloneNode(1) }

sub find {
    my ($self, $xpath) = @_;

    unless ( $xpath =~ m{(?: ^/ | ^id\( | [:\[@] )}x ) {
        $xpath = HTML::Selector::XPath::selector_to_xpath($xpath);
    }

    my $nodes = $self->body->findnodes($xpath);

    if ( $nodes->size == 0 ) {
        return;
    } elsif ( $nodes->size == 1 ) {
        return Snippet::Element::Node->new(
            body   => $nodes->get_node(0),
            parent => $self,
        ) ;
    } else {
        return Snippet::Element::NodeList->new(
            body   => $nodes,
            parent => $self,
        );
    }
}

# private 

sub _parse_html_nodes {
    my ( $self, $html ) = @_;

    # NOTE:
    # I am not sure I like this <doc/> wrapper
    # but it does give us some more flexibility
    # in the API. It just feels wrong.
    # - SL

    my @nodes = $PARSER->parse_string("<doc>$html</doc>")->documentElement->getChildnodes;

    #$self->body->getOwner->adoptNode($_) for @nodes;

    return @nodes;
}

require Snippet::Element::Document;
require Snippet::Element::Node;
require Snippet::Element::NodeList;

1;

__END__

