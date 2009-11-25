package PerlDocJp::Model::Dist;

use strict;
use parent 'Catalyst::Model';
use Moose;
with "PerlDocJp::Model::Role";
no Moose;

sub get_all {
    my($self) = @_;
    my @return;
    my @rs = $self->db->resultset('Dist')->search({
    }, {
        '+select' => [ qw/author_id.author_uid author_id.author_name/ ],
        '+as'     => [ qw/          author_uid           author_fullname/ ],
        join => { dist_authors => 'author_id' },
    })->all;

    for(@rs){
        my %hash = $_->get_columns;
        $hash{author_uid_lc} = lc($hash{author_uid});
        push(@return, \%hash);
    }
    \@return;
}

sub get {
    my($self, $dist_name) = @_;
    my %row = $self->db->resultset('Dist')->search({
        dist_name => $dist_name,
    }, {
        '+select' => [ qw/author_id.author_uid author_id.author_name/ ],
        '+as'     => [ qw/          author_uid           author_fullname/ ],
        join => { dist_authors => 'author_id' },
    })->next->get_columns;
    $row{author_uid_lc} = lc($row{author_uid});
    return \%row;
}
1;
