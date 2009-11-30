package PerlDocJp::Schema::Result::PackageTranslation;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components("Core");
__PACKAGE__->table("package_translation");
__PACKAGE__->add_columns(
  "module",
  {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 256,
  },
  "dist",
  {
    data_type => "VARCHAR",
    is_nullable => 0,
    size => 256,
  },
  "version",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
  },
  "file",
  {
    data_type => "VARCHAR",
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("module");

1;
