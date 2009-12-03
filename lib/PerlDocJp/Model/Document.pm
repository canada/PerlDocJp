package PerlDocJp::Model::Document;
use Moose;
use namespace::clean -except => qw(meta);

extends 'Catalyst::Model';
with "PerlDocJp::Model::Role";

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
    my @rs = $self->schema->resultset('Document')->search({
        doc_loc => { LIKE => "$loc/%"},
        %$cond,
    }, {})->all;
    \@rs;
}

__PACKAGE__->meta->make_immutable();

1;
