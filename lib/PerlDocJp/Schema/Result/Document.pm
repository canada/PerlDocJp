package PerlDocJp::Schema::Result::Document;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("document");
__PACKAGE__->add_columns(
  "doc_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "doc_name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "doc_loc",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "dist_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "is_module",
  { data_type => "TINYINT", default_value => undef, is_nullable => 0, size => 1 },
  "doc_desc",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 256,
  },
);
__PACKAGE__->set_primary_key("doc_id");
__PACKAGE__->has_many(
  "document_dists",
  "PerlDocJp::Schema::Result::DocumentDist",
  { "foreign.document_id" => "self.doc_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-21 04:10:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2Y9PicNVESpkbRmDRSGR7g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
