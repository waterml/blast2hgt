#!/usr/bin/env perl -w
#get all taxids under a given taxid (e.g. 2, 4751), also print itself
#require mysql database
die "Usage: perl $0 [taxid_wanted]\n" unless ($ARGV[0]);

use DBI;
my $dbh = DBI->connect("DBI:mysql:database=taxonnode;host=mgmt01;port=93306", "test", "1234", {'RaiseError' => 1}); #modify here according to your mysql setting
my %ta; #store taxonid full path
$top=$ARGV[0];
chomp($top);
print STDERR 'Target.taxids.from: ', $top, "\n";
push @pool, $top; #store parent_id
print $top."\n"; #also print itself
while (@pool){
	$current=pop @pool;
	my $sth = $dbh->prepare("SELECT tax_id FROM ncbi_nodes WHERE parent_tax_id=$current");
	# print STDERR $current."\n";
	$sth->execute();
	if($ref = $sth->fetchall_arrayref()){ #fetchall_arrayref() stores ref of the entire result of a query, which may have multiple rows
		$sth->finish;
		foreach $r (@$ref){
			print values @{$r},"\n"; # OR: print join(' ', @{$r}),"\n";
			push @pool, @$r;
		}
		# print join (' ', @pool),"\n";
	}else{
		# Actually fetchall_arrayref will not return FALSE even when no result found,
		# So here would never be executed.
		print STDERR "No.more.Subgroup.taxids.Found.for: $current.\n";
	}
}
