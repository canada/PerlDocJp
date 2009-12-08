package PerlDocJp::Schema::Result::DistAuthor;

use strict;
use warnings;

use base 'PerlDocJp::Schema::Result';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("dist_author");
__PACKAGE__->add_columns(
  "dist_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "author_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("dist_id", "author_id");
__PACKAGE__->belongs_to(
  "author_id",
  "PerlDocJp::Schema::Result::Author",
  { author_id => "author_id" },
);
__PACKAGE__->belongs_to(
  "dist_id",
  "PerlDocJp::Schema::Result::Dist",
  { dist_id => "dist_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-21 04:10:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KLouebgIuQfODHbId9HHjQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
