use AnyEvent::HTTP;
use Web::Scraper;
use strict;

my $dir = "search_result/";

main();
exit;

sub main {
    my $fetch = 0;
    my $scrape = 1;
    my @dist = split(/\n/, `ls /data/perldocjp/docs/modules/`);
    my @result;

    @result = $fetch ? fetch(@dist) : grep { $_ and $_ = "$dir$_" } @dist;

    scrape(@result) if $scrape;
}

sub fetch {
    my(@dist) = @_;
    my @result;
    my $cv = AnyEvent->condvar; # 1つのcvで……

    print "loop begin.\n";

    for my $dist (@dist){
        next unless $dist;

        my $query = dist2mod($dist);
        print("http://search.cpan.org/search?query=$query&mode=all\n");
        $cv->begin;
        print "get $query\n";
        http_get("http://search.cpan.org/search?query=$query&mode=all", sub {
                print "got $query\n";
                open(my $save, ">$dir$dist");
                print $save $_[0];
                close($save);
                push @result, "$dir$dist";
                $cv->end; # endを送る。
            });
    }
    print "loop done.\n";
    $cv->recv;
    print "recv done.\n";
    return @result;
}

sub scrape {
    my(@result) = @_;
    my $scraper = scraper { process '.sr > a', link => '@href' };

    for(@result){
        open(my $fh, $_) or die $!;
        my $contents = join(q{}, <$fh>);
        my $res = $scraper->scrape($contents);
        #print "$_ : $res->{link} \n";
        my ($author, $dist_ver) = extract_url($res->{link});
        my $dist = dist2mod($dist_ver, '-');
        my ($local_dist) = m{([^/]+)$};
        $local_dist = dist2mod($local_dist, '-') ;
        if ($local_dist ne $dist){
            $author = '*UNKNOWN*';
            $dist_ver = $_;
        }
        $local_dist = dist2mod($local_dist, '::') ;
        s{^search_result/}{};
        $dist_ver =~ s{^search_result/}{};
        print "INSERT INTO dist (dist_name, author_name, latest_release, mod_name) VALUES ('$_' ,'$author', '$dist_ver', '$local_dist');\n";
    }
}

sub dist2mod {
    my($dist, $join) = @_;
    my @mod;

    my @dist = split(/-/, $dist);
    for(@dist){
        next if m#\.# && m#[0-9]#;
        push @mod, $_;
    }
    return join($join ? $join : "::", @mod);
}

sub extract_url {
    my($uri) = @_;
    my (undef, $author, $dist) = split(m#/#, $uri);
    $author =~ s/^~//;
    $author = uc($author);
    return ($author, $dist);
}
