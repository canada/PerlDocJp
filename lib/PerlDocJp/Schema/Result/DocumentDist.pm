package PerlDocJp::Schema::Result::DocumentDist;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("document_dist");
__PACKAGE__->add_columns(
  "document_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "dist_id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("document_id", "dist_id");
__PACKAGE__->belongs_to(
  "dist_id",
  "PerlDocJp::Schema::Result::Dist",
  { dist_id => "dist_id" },
);
__PACKAGE__->belongs_to(
  "document_id",
  "PerlDocJp::Schema::Result::Document",
  { doc_id => "document_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-21 04:10:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:H/kgnMrfDNFk8fNDxUjzAQ

__PACKAGE__->has_many(
  "dist_authors",
  "PerlDocJp::Schema::Result::DistAuthor",
  { "foreign.dist_id" => "self.dist_id" },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
