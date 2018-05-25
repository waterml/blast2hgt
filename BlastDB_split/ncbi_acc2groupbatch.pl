#!/usr/bin/env perl -w
#Remember to modify database/host/password (line 11) according to your own settings
#get groups'(e.g. all bacteria's) accession number from ncbi nr/nt
#known issue: some taxid have been merged, cannot determine acc under them
#perl ~/li/iapp/ncbi_acc2group.pl allnr.acc.taxid.gi 2 4751 >output
#see end for input format

die "Usage: perl $0 [nr/nt:acc_taxid] [group_taxid_file] \ncannot overlaps\n" unless ($ARGV[1]);

use DBI;
my $dbh = DBI->connect("DBI:mysql:database=taxonnode;host=localhost", "test", "1234", {'RaiseError' => 1});
my %ta; #store taxonid full path

open TXD, "$ARGV[1]" or die "ERRopen $ARGV[1] \n";
while(<TXD>){ #taxid list
	chomp;
	next if /^$|^\s+$|^\#/; #skip blankLine
	$list{$_}=1;
}
close TXD;
print STDERR 'Target.Groups: ', join(' ', sort keys %list),"\n";

open IN, "$ARGV[0]" or die "ERRopen $ARGV[0] \n";
while(<IN>){
	next if /^$|^\s+$/; #skip blankLine
	chomp;
	my @arr=split / /;
	push @{$ta{$arr[1]}}, $arr[0]; #array hash: each_taxid - each_taxid's_ACCs
}
close IN;

foreach $group(sort keys %list){
	if($ta{$group}){ #current id under target group directly
		push @{$ok{$group}}, @{$ta{$group}};
		delete $ta{$group};
	}
}

OUTER:foreach $id(sort keys %ta){
	$taxid=$id;
	$f=0; #dont use $result for flag, it is redefined in $result=$sth->fetchrow_array() 
	while ($f==0){ # =9 if reach root
		my $sth = $dbh->prepare("SELECT parent_tax_id FROM ncbi_nodes WHERE tax_id=$taxid");
		$sth->execute();
		if ($result = $sth->fetchrow_array()){ #get 1 taxid 1 loop time, while is slow
			if ($result==1){
				print STDERR "$id Reached 1, still_unkown\n"; 
				push @noclass, @{$ta{$id}}; #give unclassified group
				$f=9; next OUTER;
			}else{
				foreach $group(sort keys %list){ #$result==$group, push&&next
					if ($result == $group){
						push @{$ok{$group}}, @{$ta{$id}};
						next OUTER;
					}
				}
				$taxid=$result;
			}
		}else{
			print STDERR "$id\t$taxid\tNoParentTaxid.unclassified\n";
			push @noclass, @{$ta{$id}};
			next OUTER;
		}
	}
}

foreach (sort keys %ok){
	open OT, ">$_.acc";
	print OT join("\n", @{$ok{$_}}), "\n";
	close OT;
}
open OTN, ">nogroup.acc";
print OTN join("\n", @noclass), "\n";
close OTN;

=cut Input $ARGV[0]:
acc taxid gi
==> allnr.acc.taxid.gi <==
WP_003131952.1 1358 489223532
NP_268346.1 272623 15674171
Q9CDN0.1 272623 13878750
Q02VU1.1 272622 122939895
A2RNZ2.1 416870 166220956
AAK06287.1 272623 12725253
ABJ73931.1 272622 116108791
CAL99037.1 416870 124494037
ADA65983.1 684738 281376497
ADJ61439.1 746361 300072039

=pod
