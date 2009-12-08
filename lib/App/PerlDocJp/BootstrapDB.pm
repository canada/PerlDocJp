package App::PerlDocJp::BootstrapDB;
use Moose;
use PerlDocJp::Schema;
use namespace::clean -except => qw(meta);

with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';

has connect_info => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

has drop => (
    is => 'ro',
    isa => 'Bool',
    default => 1,
);

sub run {
    my $self = shift;

    my $schema = PerlDocJp::Schema->connection(@{ $self->connect_info });

    my $guard = $schema->txn_scope_guard();
    $schema->deploy( {
        quote_field_names => 0,
        add_drop_table => $self->drop,
    } );
    $guard->commit();
}

1;