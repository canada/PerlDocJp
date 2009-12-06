package PerlDocJp::Model::Search;

1;
__END__
use strict;
use warnings;
use Estraier;

$Estraier::DEBUG = 1;


my $db = new Database();
$db->open("/data/perldocjp/canada/he/casket", Database::DBREADER) || die;


sub search {
    my ($self, $query) = @_;
    # create a search condition object
    my $cond = new Condition();
    # set the search phrase to the search condition object
    $cond->set_phrase($query);
    # get the result of search
    my $result = $db->search($cond);

    my @return;

    foreach my $loop (0 .. $result->doc_num() - 1){
        my %row;
        # retrieve the document object
        my $doc = $db->get_doc($result->get_doc_id($loop), 0);
        next unless(defined($doc));
        # display attributes
        $row{uri}    = $doc->attr('@uri')    || "";
        $row{title}  = $doc->attr('@title')  || "";
        $row{author} = $doc->attr('@author') || "";
        $row{misc}   = $doc->attr('@misc')   || "";
        $row{cdate}  = $doc->attr('@cdate')  || 0;
        $row{mdate}  = $doc->attr('@mdate')  || 0;
        ($row{author_uid}, $row{author_name}) = split(" / ", $row{author}, 2);
        $row{author_uid} = lc($row{author_uid});
        $row{cdate} =~ s/T.*$//;
        $row{mdate} =~ s/T.*$//;
        ($row{dist_name})   = $row{uri} =~ m{^/[^/]+/([^/]+)/};
        ($row{dist_uri})    = $row{uri} =~ m{^(/[^/]+/[^/]+/)};
        push(@return, \%row);
    }
    return \@return;
}

sub DESTROY {
    my ($self) = @_;
    # close the database
    unless($self->db->close()){
        printf("error: %s\n", $self->db->err_msg($self->db->error()));
    }
}
1;
