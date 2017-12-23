#!/usr/bin/perl -w
#auto determine acc or gi from Refseq Protein, query its taxid
#inputFile: $name\t$acc\t$evalue(or_other_col)
use DBI;
my $dbh = DBI->connect("DBI:mysql:database=taxondb;host=localhost", "test", "1234", {'RaiseError' => 1});
$no=0; #count no results query;
while(<>){
	next if /^\s+$/;#skip blankLine
	chomp;
	if(/\t.*?\t/){ #standard from blastout
		my @arr=split /\t/;
		$acc=$arr[1];
	}else{ #single column
		$acc=$_;
	}
	$acc=~s/\..*//; #remove .1 .2 if needed
	if($cache{$acc}){ # cached
		print "$_\t$cache{$acc}\n";
	}elsif($non{$acc}){ # cached non-exists, next
		$no++; next;
	}else{
		if($acc=~/[A-Za-z]/){$header='accession';}else{$header='gi';} #acc OR gi
		my $sth = $dbh->prepare("SELECT taxid FROM refseqProtein_acc_taxid_gi WHERE $header='$acc'");
		$sth->execute();
		if($result = $sth->fetchrow_array()){
			print "$_\t$result\n";
			$cache{$acc}=$result; #cache for next time
		}else{ #cache for no result
			$non{$acc}=1; $no++;
		}
	}
}
print STDERR join("\n", sort keys %non), "\n";
print STDERR scalar keys %non, " queries no taxid.\n$no lines no taxid.\n";
$dbh->disconnect();
