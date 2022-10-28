#!/usr/bin/perl -w
#list all downstream tax_id for input
# perl taxonid_downstream.pl 214506 1 >214506.subtaxid.txt
# will get sub-taxid (1 level), but not include sub-sub-taxid, sub-sub-sub-taxid...
die "Usage: perl $0 [tax_id] [level3] >output" unless @ARGV;
use DBI;
my $dbh = DBI->connect("DBI:mysql:database=taxonnode;host=mgmt01;port=93306", "test", "1234", {'RaiseError' => 1});

@ta=($ARGV[0]);
if($ARGV[1]){$level=$ARGV[1];}else{$level=999999999999999999999999999999;}
my $f=0;
while (@ta){
	$taxid=pop @ta; $f++;
	my $sth = $dbh->prepare("SELECT tax_id FROM ncbi_nodes WHERE parent_tax_id=$taxid");#trace downstream tax_id
	$sth->execute();
	# print $taxid, "\n" if ($sth->rows == 0); #only print end taxonid
	while($result = $sth->fetchrow_array()){
		print $result, "\n"; #print all sub taxonid
		push @ta, $result if $f <$level;
	}
}
$dbh->disconnect();
