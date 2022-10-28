#!/usr/bin/perl -w
use DBI;
my $dbh = DBI->connect("DBI:mysql:database=taxonnode;host=mgmt01;port=93306", "test", "1234", {'RaiseError' => 1});
while(<>){
	chomp;
	$result=$_;
#get scientific name per upstream taxon_id
	my $sti = $dbh->prepare("SELECT name_txt FROM ncbi_names WHERE tax_id=$result AND name_class='scientific name'");
	$sti->execute();
	while ($name = $sti->fetchrow_array()){
		print "$result\t$name\n";
	}
}
