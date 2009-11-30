package PerlDocJp::Model::Author;

use strict;
use parent 'Catalyst::Model';

use Moose;
with "PerlDocJp::Model::Role";
no Moose;

sub get {
    my($self, $uid) = @_;
    my %rs = $self->db->resultset('Author')->search({
        author_uid => $uid,
    }, {})->next->get_columns();
    \%rs;
}

sub get_by_alphabet {
    my($self, $alpha) = @_;
    my $rs = $self->db->resltset('Author')->search({
        author_uid => { 'LIKE' => "$alpha\%" },
    },{
          order_by => 'author_uid',
    });
    return $rs;
}

sub get_dist {
    my($self, $id) = @_;

    my @rs = $self->db->resultset('DistAuthor')->search({
        author_id => $id,
    }, {
        "+select" => [ qw/dist_id.dist_name dist_id.latest_release/ ],
            "+as" => [ qw/dist_name latest_release/ ],
            join  => 'dist_id',
    })->all;
    my @return;
    foreach(@rs){
        my %row = $_->get_columns();
        push(@return, \%row);
    }
    \@return;
}
1;
