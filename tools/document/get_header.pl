#! /usr/bin/perl -w

use strict;
use File::Find ();
use Encode;
use Encode::Guess qw/euc-jp utf8 shiftjis 7bit-jis/;

my $dir = '/data/perldocjp/docs/modules/';
my $table = 'document';

my $max = 0;
File::Find::find({wanted => \&wanted}, $dir);
exit;


sub wanted {
    if(/^(.*\.pod)\z/s){
        my $file = $_;
        my $old;
        my $abs_dir = $File::Find::name;
        my $ver = get_ver($abs_dir);
        my $found = 0;
        my $count = 0;

        open(my $fh, $file);

        # search header
        while($_ = <$fh>) { 
            $count++;
            ($old = $_) and $found = $. and last if (/(.*)\s\--?\s(.*)/);
            last if /^=head1/;
        };

        if(not $old){
            while($_ = <$fh>) { 
                ($old = $_) and $found = $. and last if (/(.*)\s\--?\s(.*)/);
            };
        }

        if (/^[ !-~]+$/){ # all of printable ASCII
            while($_ = <$fh>) {
                last if (/(.*)\s\--?\s(.*)/);
            };
        }

        close($fh);

        my $flag = 0;
        ($_ = $old and $flag = 1) if(eof && $old);

        my $rel_dir = $abs_dir;
        $rel_dir =~ s/^$dir//;

        $_ = $old if($. > 15 && $old);
        /(.+?)\s+\-+\s+(.*)/;
        my $modname = $1;
        my $desc = $2;
        $modname = 'Mysql' if ($modname =~ m{Msql / Mysql});

        open($fh, $file);
        my $doc = join(q{}, <$fh>);
        close($fh);

        clean_modname(\$modname);

        $desc = to_utf8($desc, \$doc);


        my $is_mod = 1;
        if(($found - $count > 15) || (not $found) || $modname !~ /^(?:[a-z0-9_]+::)*[a-z0-9_]+(?:::)?$/oi){
            #$modname = $file;
            #$desc    = q{};
            $is_mod  = 0;
        }

        if($found - $count > 15){
            $modname = $file;
            $desc    = $file;
        }else{
            $max = ( ($found - $count) > $max) ? ($found - $count) : $max;
        }

        escape_sql(\$rel_dir);
        escape_sql(\$modname);
        escape_sql(\$desc);
        print ("INSERT INTO $table (doc_loc, doc_name, doc_desc, is_module) VALUES ('$rel_dir', '$modname', '$desc', $is_mod);\n");
    }
    elsif(-f $_ && $File::Find::name !~ m{/CVS}) {
        my $rel_dir = $File::Find::name;
        $rel_dir =~ s/^$dir//;
        escape_sql(\$rel_dir);
        print "INSERT INTO $table (doc_loc, doc_name, doc_desc, is_module) VALUES ('$rel_dir', '$_', '$_', 0);\n";
    }
        
}

sub clean_modname{
    my($modname) = @_;
    $$modname =~ s/^\s+//;
    $$modname = $1 if($$modname =~ /[A-Z]<(.*)>/);
    $$modname =~ s/^\=[0-9a-z]+\s*//i;
    $$modname =~ s/.pm$//i;
}

sub get_ver{
    my($file) = @_;
    my $dist = $file;
    $dist =~ s{$dir}{};
    $dist =~ s{/.*$}{};
    my @dist = split(/-/, $dist);
    pop(@dist);
}

sub to_utf8{
    my($desc, $doc) = @_;
    my $enc = guess_encoding($$doc or $desc, qw/utf8 euc-jp shiftjis 7bit-jis/);
    $enc = ref($enc) ? $enc->name : 'euc-jp';

    $desc = Encode::decode($enc, $desc);
    Encode::encode('utf8', $desc);
}

sub escape_sql{
    my($value) = @_;
    $$value =~ s/'/''/g;
    return $value;
}
