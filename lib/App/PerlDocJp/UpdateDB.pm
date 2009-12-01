# XXX This is currently a hackish piece of shit.

package App::PerlDocJp::UpdateDB;
use utf8;
use Moose;
use Encode;
use File::Basename qw(basename);
use File::Find::Rule;
use PerlDocJp::Schema;
use MooseX::Types::Path::Class;
use namespace::clean -except => qw(meta);

with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';

has connect_info => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

has package_details => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
);

has pod_dir => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    coerce => 1,
    required => 1,
);

has schema => (
    is => 'ro',
    isa => 'PerlDocJp::Schema',
    lazy_build => 1,
);

sub _build_schema {
    my $self = shift;
    return PerlDocJp::Schema->connect( @{ $self->connect_info} );
}

sub run {
    my $self = shift;

    $self->update_translated_pod_list;
    $self->update_package_details;
}

sub update_translated_pod_list {
    my $self = shift;
    my $pod_dir = $self->pod_dir;

    my $parser_class = Moose::Meta::Class->create_anon_class(
        superclasses => [ 'Pod::Parser' ],
        attributes   => [
            Moose::Meta::Attribute->new(
                encoding => (
                    is => 'rw',
                    isa => 'Str',
                    default => 'euc-jp',
                    clearer => 'clear_encoding',
                )
            ),
            Moose::Meta::Attribute->new(
                name => (
                    is => 'rw',
                    isa => 'Str',
                    clearer => 'clear_name',
                )
            ),
        ],
        methods      => {
            reset => sub {
                my $self = shift;
                $self->encoding('euc-jp');
                $self->clear_name;
            },
            command => sub {
                my ($self, $command, $para) = @_;
                # if we have multiple lines, just use the first one
                if ($para =~ /\n/) {
                    ($para) = split /\n/, $para;
                }
                $para = decode($self->encoding, $para);
                if ($para eq 'NAME' || $para eq '名前') {
                    $self->{in_name} = 1;
                } elsif ($command eq 'encoding') {
                    $self->encoding( $para );
                }
            },
            textblock => sub {
                my ($self, $para) = @_;
                $para = decode($self->encoding, $para);
                if ($self->{in_name}) {
                    # if we have multiple lines, just use the first one
                    if ($para =~ /\n/) {
                        ($para) = split /\n/, $para;
                    }

                    $para =~ s/\s+$//;
                    $para =~ s/\s*-+\s*.*$//sm;
                    $self->name( $para );
                    delete $self->{in_name};
                }
            },
            verbatim => sub { }
        }
    );
    my $parser = $parser_class->name->new();
    my $find_pods = File::Find::Rule->file()->name('*.pod');
    my $rs = $self->schema->resultset('PackageTranslation');
    while ( my $dist = $pod_dir->next ) {
        next unless $dist->is_dir;
        next unless ($dist->dir_list(-1,1)) =~ /^(.+)-([\d\._]+)$/;

        my ($dist_name, $version) = ($1, $2);

        my @pods = $find_pods->in( $dist );

        foreach my $pod (@pods) {
            $parser->reset();
            local $parser->{pod} = $pod;
            $parser->parse_from_file($pod);
            if (! $parser->name) {
                warn "failed to retrieve for $pod";
            } else {
                if ($parser->name =~ /[^a-zA-Z0-9:_-]/ ) {
                    next;
                }
                $rs->update_or_create(
                    { dist => $dist_name, version => $version, module => $parser->name, file => $pod },
                    { key => 'is_unique_module' },
                );
            }
        }

    }
}

sub update_package_details {
    my $self = shift;
    my $schema = $self->schema;
    my $package_details = $self->package_details;
    open(my $fh, '<', $package_details)
        or confess "Could not open $package_details: $!";

    my $guard = $schema->txn_scope_guard();

    my $find_pods = File::Find::Rule->file()->name('*.pod');

    my $rs = $schema->resultset('PackageDetails');
    my $start = 0;
    while ( <$fh> ) {
        if (/^$/) {
            $start++;
            next;
        }
        next unless $start;

        chomp;
        my ($module, $version, $path) = split /\s+/;

        if ($version eq 'undef') {
            $version = undef;
        }
            
        # Check if we have a module of the same name in our translated
        # POD directory
        (my $dist_ver = basename($path)) =~ s/\.tar.gz$//;;

        $rs->update_or_create(
            {
                module  => $module,
                dist    => 'DUMMY',
                version => $version,
                path    => $path,
            },
            { key => 'is_unique_module' },
        );
    }

    $guard->commit;
}

sub _build_package_details {
    my $self = shift;

    require CPAN;
    require File::Spec;
    require File::Temp;
    require LWP::UserAgent;
    # fetch the latest 02packages.details.txt file
    CPAN::HandleConfig->load unless $CPAN::Config_loaded++;

    my $ua       = LWP::UserAgent->new();
    my $temp_dir = File::Temp::tempdir( CLEANUP => 1, TEMPDIR => 1 );
    my $local    = File::Spec->catfile($temp_dir, '02packages.details.txt');
    foreach my $host (@{ $CPAN::Config->{urllist} }) {
        $host =~ s/\/$//;
        my $remote = "$host/modules/02packages.details.txt";
        warn $remote;
        my $res    = $ua->mirror( $remote, $local );
        if ($res->is_success) {
            $self->{__tempdir} = $temp_dir;
            return $local;
        }
    }

    confess "Could not download 02packages.details.txt from any server";
}

1;

