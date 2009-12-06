package PerlDocJp::Model::WithDBIC;
use Moose::Role;
use namespace::clean -except => qw(meta);

has schema => (
    is => 'rw',
    isa => 'DBIx::Class::Schema',
    predicate => 'has_schema',
);

sub ACCEPT_CONTEXT {
    my ($self, $c) = @_;

    # XXX Model::DBIC creates random shit for us, so this is kind of a
    # waste of memory, but anyway...
    if (! $self->has_schema) {
        $self->schema( $c->model('DBIC')->schema );
    }
    return $self;
}

1;