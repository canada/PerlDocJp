#! /usr/bin/perl -w
    eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
        if 0; #$running_under_some_shell

use strict;
use File::Find ();
use POSIX qw/strftime/;
use Encode;
use Encode::Guess;
use lib qw(/home/canada/Catalyst/PerlDocJp/lib/);


# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# for the convenience of &wanted calls, including -eval statements:

use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

sub wanted;

use PerlDocJp::Schema;
my $schema = PerlDocJp::Schema->connect('dbi:mysql:perldocjp', 'root', 'mymymy');
my $local; chomp($local = `pwd`);
my $root = '/data/perldocjp/docs/modules';
# Traverse desired filesystems
system("rm -rf est/*");
File::Find::find({wanted => \&wanted}, $root);
exit;


sub wanted {
    return if $name =~ m{\bCVS\b};

    my($dev,$ino,$mode,$nlink,$uid,$gid, $rdev, $size, $atime, $mtime, $ctime) = stat($_);

    my $fname = $name;
    $fname =~ s/^$root//;
    $fname =~ s/^\///;
    return if not $fname;

    my $abs = "$local/est/$fname";

    if(-d _){
        print "$abs\n";
        mkdir $abs or die $!;
    }
    elsif(-f _){
        my %desc;
        eval {
            %desc = $schema->resultset('Document')->search({
                doc_loc => $fname,
            },{
                '+select' => [ qw/author_id.author_uid author_id.author_name/ ], 
                '+as'     => [ qw/author_uid author_name/ ], 
                join      => { document_dists => { dist_authors => 'author_id' } },
            })->next->get_columns;

        };

        next unless %desc;
        $desc{author_uid_lc} = lc($desc{author_uid});
        $mtime = strftime("%Y-%m-%dT%H:%M:%S+0900", localtime($mtime));
        $ctime = strftime("%Y-%m-%dT%H:%M:%S+0900", localtime($ctime));

        open(my $fh, "<$dir/$_") or die $!, $abs;
        print "$dir";
        my $contents = join(q{}, <$fh>);
        $contents = to_utf8(\$contents);
        close($fh);

        open($fh, ">$local/est/$fname.est");
        print $fh <<EOF;
\@uri=/~$desc{author_uid_lc}/$desc{doc_loc}
\@title=$desc{doc_name}
\@author=$desc{author_uid} / $desc{author_name}
\@mdate=$mtime
\@cdate=$ctime
\@misc=$desc{doc_desc}

$contents
EOF
        close($fh);
    }
}

sub to_utf8{
    my($desc) = @_;
    my $enc =guess_encoding($$desc, qw/utf8 euc-jp shiftjis 7bit-jis/);
    $enc = ref($enc) ? $enc->name : 'euc-jp';

    $$desc = Encode::decode($enc, $$desc);
    Encode::encode('utf8', $$desc);
}

