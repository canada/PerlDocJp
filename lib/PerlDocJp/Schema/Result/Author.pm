package PerlDocJp::Schema::Result::Author;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("author");
__PACKAGE__->add_columns(
  "author_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "author_uid",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 32,
  },
  "author_name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "author_email",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
);
__PACKAGE__->set_primary_key("author_id");
__PACKAGE__->add_unique_constraint("author_uid", ["author_uid"]);
__PACKAGE__->has_many(
  "dist_authors",
  "PerlDocJp::Schema::Result::DistAuthor",
  { "foreign.author_id" => "self.author_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-21 04:10:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:35bsk3lBYoormgdkk0bTng


# You can replace this text with custom content, and it will be preserved on regeneration
1;
