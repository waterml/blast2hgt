#!/usr/bin/perl -w
#auto determine acc or gi from nr, query its taxid
#inputFile: $name\t$acc\t$evalue(or_other_col)
use DBI;
my $dbh = DBI->connect("DBI:mysql:database=taxondb;host=localhost", "test", "1234", {'RaiseError' => 1});
$no=0; #count no results query;
while(<>){
	next if /^\s+$/;#skip blankLine
	chomp;
	if(/\t.*?\t/){ #standard from blastout
		my @arr=split /\t/;
		$accorg=$arr[1];
	}else{ #single column
		$accorg=$_;
	}
	$accorg=~s/\..*//; #remove .1 .2 if needed
	$acc=$accorg;
	if(@{$acc}){ #stored
		print "$_\t@{$acc}\n";
		# print STDERR "stored\n";
	}elsif($non{$acc}){ # non-exists, next
		$no++;
		next;
	}else{
		if($acc=~/[A-Za-z]/){ #acc
			$header='accession';
		}else{ #gi
			$header='gi';
		}
		my $sth = $dbh->prepare("SELECT taxid FROM nr_acc_taxid_gi WHERE $header='$acc'");
		$sth->execute();
		if($result = $sth->fetchrow_array()){ #only return 1st hit
			print "$_\t$result\n";
			push @{$acc}, $result; #store for next time
		}else{ #hash for no result
			$non{$acc}=1;
		}
	}
}
print STDERR join("\n", sort keys %non), "\n", scalar keys %non;
print STDERR " queries no taxid.\n$no lines no taxid. \n";
$dbh->disconnect();
