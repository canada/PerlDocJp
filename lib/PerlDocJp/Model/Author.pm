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
    my $rs = $self->db->resultset('Author')->search({
        author_uid => { 'LIKE' => "$alpha\%" },
    },{
          order_by => 'author_uid',
    });
    return $self->_rs_hashref($rs);
}

sub get_dist {
    my($self, $id) = @_;

    my $rs = $self->db->resultset('DistAuthor')->search({
        author_id => $id,
    }, {
        "+select" => [ qw/dist_id.dist_name dist_id.latest_release/ ],
            "+as" => [ qw/dist_name latest_release/ ],
            join  => 'dist_id',
    });
    $self->_rs_hashref($rs);
}

sub _rs_hashref{
    my($self, $rs) = @_;
    my @return;

    while ($_ = $rs->next){
        my %row = $_->get_columns();
        $row{author_uid_lc} = lc($row{author_uid}) 
            if exists $row{author_uid};
        push(@return, \%row);
    }

    \@return;
}

1;
