package PerlDocJp::Schema::Result::PackageTranslation;
use strict;
use warnings;
use base qw(PerlDocJp::Schema::Result);

__PACKAGE__->load_components("Core");
__PACKAGE__->table("package_translation");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INT",
    is_nullable => 0,
    is_auto_increment => 1,
  },
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
    size => 256,
    is_nullable => 1,
  },
  "file",
  {
    data_type => "VARCHAR",
    size => 256,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(is_unique_module => [ qw(module) ]);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    my ($c) = grep {
        my $constraint = $_;
        $constraint->name eq 'is_unique_module'
    } $sqlt_table->get_constraints();

    $c->fields( [ 'module(255)' ] );
    $self->next::method( $sqlt_table );
}

1;
1;
