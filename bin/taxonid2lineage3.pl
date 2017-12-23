#!/usr/bin/perl -w
#when mysql db updated (need revision):
#egrep 'contaminant|other sequences|artificial sequences|synthetic construct|environmental samples|uncultured|unclassified sequences' ~/tools/gi2taxid/names.dmp |perl -pe 's/\t.*//' |sort |uniq >taxonid2lineage3.pl.exclude

#see end for input formate

#taxid to be ignored, e.g. 'environmental samples'
if( -e "taxonid2lineage3.pl.exclude" ){
	open EX, "taxonid2lineage3.pl.exclude";
	while(<EX>){
		next if /^$/; chomp; $en{$_}=1;
	}
	close EX;
	print STDERR "DONE Reading Excluded_list;\n", eval(scalar(keys %en)), " taxonamy to exclude.\n";
}else{
	print STDERR "No Excluded_list\n";
}

use DBI;
my $dbh = DBI->connect("DBI:mysql:database=taxonnode;host=localhost", "test", "1234", {'RaiseError' => 1})
or die "Couldn't open database: '$DBI::errstr'; stopped";
my %txn; #store taxonid full path
OUTER:while(<>){
	next if (/^\s+$|NotFound/ ); #skip blankLine, NotFound_gi
	$input=$_; chomp;
	my @arr=split /\t/;
	$taxidorg=$arr[$#arr]; #taxid is last col
	$taxid=$taxidorg;
	$f=0; #$f=1 if reach root
	INNER:while ($f==0){
		if($txn{$taxid}){ #stored,next. But if $taxid from mysql query, join them
			$txn{$taxidorg}=$txn{$taxidorg} . ' ' . $txn{$taxid} if ($taxid ne $taxidorg && $txn{$taxidorg});
			last INNER;
		}elsif($en{$taxid}){
			print STDERR "ExcludedA: $input";
			next OUTER;
		}elsif($er{$taxid}){ #known no results
			print STDERR "IgnoredA: $input";
			next OUTER;
		}else{
			my $sth = $dbh->prepare("SELECT parent_tax_id FROM ncbi_nodes WHERE tax_id=$taxid");
			$sth->execute();
			if ($result = $sth->fetchrow_array()){
				if($en{$result}){
					print STDERR "ExcludedB: $input";
					next OUTER;
				}elsif($er{$result}){
					print STDERR "IgnoredB: $input";
					next OUTER;
				}elsif($txn{$taxidorg}) { #append
					$txn{$taxidorg}=$txn{$taxidorg} . ' ' . $result;
				}else{ #new
					$txn{$taxidorg}=$result;
				}
				$f=1 if $result==1;
				$taxid=$result;
			}else{ #no parent_tax_id, skip this error line
				$er{$taxid}=1; #warning
				print STDERR "IgnoredC: $input";
				next OUTER; 
			}
		}
	}
push @org, $input; #excluded/error lines skipped
}
$dbh->disconnect();

undef $taxid;
foreach $taxid(sort keys %txn){
	print $taxid, " ", $txn{$taxid}, "\n";
}
print "\#\#\#LineageEnd\n";
print @org; #print original input

=pod input: last col is taxid(no col limit, all taxid appended after " "):
scaffold0_1039137..1039572	260184420	2e-25	125	3218
scaffold0_1039137..1039572	261362271	1e-21	113	81964
=cut