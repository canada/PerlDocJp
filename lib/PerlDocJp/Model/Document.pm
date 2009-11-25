package PerlDocJp::Model::Document;

use strict;
use parent 'Catalyst::Model';

use Moose;
with "PerlDocJp::Model::Role";
no Moose;

sub get_mod_by_loc {
    my($self, $loc) = @_;
    $self->get_by_loc($loc, {is_module => 1});
}

sub get_doc_by_loc {
    my($self, $loc) = @_;
    $self->get_by_loc($loc, {is_module => 0});
}

sub get_by_loc {
    my($self, $loc, $cond) = @_;
    my @rs = $self->db->resultset('Document')->search({
        doc_loc => { LIKE => "$loc/%"},
        %$cond,
    }, {})->all;
    \@rs;
}

1;
