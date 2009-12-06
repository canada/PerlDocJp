package App::PerlDocJp::UpdateSource;
use Moose;
use MooseX::Types::Path::Class;
use Cwd;
use Encode;
use File::Find::Rule;
use File::Temp qw(tempdir);
use Guard;
use namespace::clean -except => qw(meta);

with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';

has cmd_paths => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy_build => 1,
    required => 1,
);

has cvs => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
    required => 1,
);

has cvs_root => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    default => ':pserver:anonymous@cvs.sourceforge.jp:/cvsroot/perldocjp',
);

has cvs_modules => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [ qw(docs/modules) ] }
);

has source_dir => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    coerce => 1,
    required => 1,
);

sub _build_cmd_paths {
    my @paths = split(/:/, $ENV{PATH});
    if (! @paths) {
        @paths = qw(/opt/local/bin /usr/local/bin /usr/bin /bin);
    }
    return \@paths;
}

sub _build_cvs {
    my $self = shift;
    return $self->_search_cmd('cvs');
}

sub _search_cmd {
    my ($self, $cmd) = @_;
    my $paths = $self->cmd_paths;
    foreach my $path (@$paths) {
        my $spec = Path::Class::File->new($path, $cmd);
        if (-x $spec) {
            return $spec->stringify;
        }
    }
    confess "Could not find $cmd anywhere";
}

sub run {
    my $self = shift;

    my $tempdir = tempdir( CLEANUP => 1, TEMPDIR => 1 );

    # XXX need to have logged in
    {
        my $cwd = cwd();
        scope_guard { chdir $cwd };

        chdir $tempdir;
        foreach my $module (@{ $self->cvs_modules }) {
            system($self->cvs, '-d' . $self->cvs_root, 'co', $module) == 0
                or confess "Could not checkout module $module";
        }
    }

    # now find the POD source files, change them into UTF-8
    my @pod = File::Find::Rule->file()->name('*.pod')->in($tempdir);

    foreach my $pod (@pod) {
        $pod = Path::Class::File->new($pod);

        my $pod_fh   = $pod->openr;
        my $encoding = 'euc-jp';
        my $found    = 0;
        while (<$pod_fh>) {
            if (/^=encoding\s+([\w_-]+)/) {
                $encoding = $1;
                $found++;
                last;
            }
        }
        $pod_fh->seek(0, 0);

        my $parent = $self->source_dir->subdir( $pod->parent->relative( $tempdir ) );
        if (! -d $parent) {
            $parent->mkpath or confess "Could not create dir $parent"; 
        }
        my $outfile = $parent->file( $pod->basename );
        my $out_fh = $outfile->openw;
        binmode($out_fh, ':utf8');

        if (! $found) {
            print $out_fh "=encoding utf-8\n\n";
        }
        while (<$pod_fh>) {
            s/^=encoding.*/=encoding utf-8/;
            print $out_fh decode($encoding, $_);
        }
    }
}

1;