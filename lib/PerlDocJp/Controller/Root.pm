package PerlDocJp::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use YAML::Syck;
use Encode;
use Encode::Guess qw/eucjp utf8 shiftjis 7bit-jis/;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

PerlDocJp::Controller::Root - Root Controller for PerlDocJp

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut


sub begin :Private {
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{items}{body} = 'onload="document.f.query.focus();" class="front"';
}

# template does everything
sub faq :Local { } 
sub feedback :Local { }
sub mirror :Local { }

sub search :Local {
    my ( $self, $c ) = @_;
    my $db = $c->model('Search');
    my $query = $c->req->param('query');
    my $result = $db->search($query);
    $c->stash->{items}{found} = @$result + 0;
    $c->stash->{items}{result} = $result;
}


use Pod::L10N::Html;
use POSIX (qw/setsid/);
use Apache2::SubProcess;

sub pod :LocalRegex('^~([-a-z*]+)/([^/]+)/(.+)$') {
    my ( $self, $c) = @_;

    my $dir  = $c->config->{source}{modules};
    my $auth = $c->req->snippets->[0];
    my $dist = $c->req->snippets->[1];
    my $doc  = $c->req->snippets->[2];
    my $html;

    if($doc =~ /\.pod$/){
        my $fifo = "/var/lib/perldocjp/l10n_html"; # it must be named pipe or documents will be out of order.

        mkdir("/tmp/perldoc_$$") or die;
        chdir("/tmp/perldoc_$$");
        $SIG{CHLD} = 'IGNORE';
        if(my $pid = fork){
            open(my $read, "<$fifo");
            $html = join(q{}, <$read>);
            close($read);
            wait;
        }elsif(defined $pid){
            mkdir("/tmp/perldoc_$$");
            chdir("/tmp/perldoc_$$");
            setsid;
            pod2html("$dir$dist/$doc", "--outfile=$fifo");
            CORE::exit(0);
        }else{
            $c->log->warn("Can't fork...");
        }

        $html = Encode::decode('Guess', $html);
        $html = Encode::encode('utf8', $html);
        $html =~ s/^.*?<body [^>]+?>//s;
        $html =~ s/^(.*)<\/body>.*$/$1/s;
        $html =~ s/<h([1-5])><a /<h$1><a href="#__index__" class='u' title="click to top of document" /ig;
        $html = qq{<div class="pod">$html</div>};

        $doc =~ s/\.pod$//;
        $doc =~ s#/#::#g;
    }
    $c->{stash}{items}{html}   = $html; 
    $c->{stash}{items}{author} = $auth;
    $c->{stash}{items}{dist}   = $dist;
    $c->{stash}{items}{module} = $doc;
}

sub dist :LocalRegex('^~([-a-z*]+)/([^/]+)/?$') {
    my ( $self, $c ) = @_;
    # author-name fetched by snippets can invalid value. Never use it.
    $c->req->snippets->[0] = undef;

    my $dir = $c->config->{source}{modules};
    my $dist_name = $c->req->snippets->[1];

    my $doc  = $c->model('Document');
    my $dist = $c->model('Dist');

    $c->{stash}{items}{pod}  = $doc->get_mod_by_loc($dist_name);
    $c->{stash}{items}{doc}  = $doc->get_doc_by_loc($dist_name);
    $c->{stash}{items}{dist} = $dist->get($dist_name);

}

sub modlist :Local {
    my ( $self, $c ) = @_;
    my $dist;
    my $items;

    my $dist = $c->model('Dist');
    $dist->db($c->model('DBIC'));

    $c->{stash}{items} = $dist->get_all();
}

sub _dist2mod {
    my($self, $dist, $join) = @_;
    my @mod;
    my $ver;
    my @dist = split(/-/, $dist);
    for(@dist){
        if(m/^[._0-9]+$/){
            $ver = $_;
            next;
        }
        push @mod, $_;
    }
    return (join($join ? $join : "::", @mod), $ver);
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
