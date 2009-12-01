package PerlDocJp::Schema::Result::Dist;

use strict;
use warnings;

use base 'PerlDocJp::Schema::Result';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("dist");
__PACKAGE__->add_columns(
  "dist_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "author_name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 32,
  },
  "dist_name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 128,
  },
  "latest_release",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 128,
  },
);
__PACKAGE__->set_primary_key("dist_id");
__PACKAGE__->has_many(
  "dist_authors",
  "PerlDocJp::Schema::Result::DistAuthor",
  { "foreign.dist_id" => "self.dist_id" },
);
__PACKAGE__->has_many(
  "document_dists",
  "PerlDocJp::Schema::Result::DocumentDist",
  { "foreign.dist_id" => "self.dist_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-21 04:10:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iOFV04KrPCgRUnvEeKqVXA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
