package PerlDocJp::Model::Role;

use strict;

use Moose::Role;

has db => (
    is => 'rw',
    isa => 'PerlDocJp::Model::DBIC',
    default => sub { new PerlDocJp::Model::DBIC },
);

no Moose::Role;

1;
