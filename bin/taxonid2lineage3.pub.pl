#!/usr/bin/perl -w
#when mysql db updated (need revision):
# cat ~/tools/gi2taxid/names.dmp |grep 'scientific name' |egrep 'contaminant|other sequences|artificial sequences|synthetic construct|environmental samples|uncultured|unclassified sequences' |perl -pe 's/\t.*//' |sort |uniq >taxonid2lineage3.pl.exclude

#give those excluded: 'fake'
#*.lin is individual file, use with *.taxid
#see end for input format

use Getopt::Long;
use DBI;

my $excludefile='';
GetOptions("ex=s" => \$excludefile);
&USAGE unless $#ARGV==0;
#taxid to be excluded, e.g. 'environmental samples'
if($excludefile ne ''){
	open EX, "$excludefile" or die "Error_Open $excludefile: $! \n";
	while(<EX>){
		next if /^$|\#/; chomp; $en{$_}=1;
	}
	close EX;
	print STDERR "DONE_Reading_Excluded_list: $excludefile \n";
	print STDERR eval(scalar(keys %en)), " taxonamy to exclude.\n";
}else{ print STDERR "No Excluded_list\n"; }

my $dbh = DBI->connect("DBI:mysql:database=taxonnode;host=localhost", "test", "1234", {'RaiseError' => 1})
or die "Couldn't open database: '$DBI::errstr'; stopped";
my %txn; #store lineage: taxonid full path
OUTER:while(<>){
	next if (/^\s+$|NotFound/ ); #skip blankLine, NotFound_gi
	$input=$_; chomp;
	my @arr=split /\t/;
	$taxidorg=$arr[$#arr]; #taxid is last col
	$taxid=$taxidorg;
	$f=0; #$f=1 if reach root
	while ($f==0){
		if($txn{$taxid}){ #stored, next. if $taxid from mysql query, join them
			if ($taxid ne $taxidorg){ #$taxid ne $taxidorg indicates $txn{$taxidorg} exists
				if($txn{$taxid} ne 'fake'){
					$txn{$taxidorg}=$txn{$taxidorg} . ' ' . $txn{$taxid};
				}else{$txn{$taxidorg}='fake';}
			}else{
				if($txn{$taxid} eq 'fake'){
					print STDERR "Already_Excluded: $input";
				}elsif($txn{$taxid} eq 'unknown'){
					print STDERR "Already_Unclassified: $input";
				}
				#$txn{$taxid} ne 'fake': good std result, next 
			}
			next OUTER;
		}elsif($en{$taxid}){
			$txn{$taxidorg}='fake'; #excluded: 'fake'
			print STDERR "ExcludedA: $input"; next OUTER;
		}elsif($er{$taxid}){ #known no results
			$txn{$taxidorg}='unkown'; #unclassified: 'unkown' to ignore, OR comment this line to leave as 'other'
			print STDERR "UnclassifiedA: $input"; next OUTER;
		}else{
			my $sth = $dbh->prepare("SELECT parent_tax_id FROM ncbi_nodes WHERE tax_id=$taxid");
			$sth->execute();
			if ($result = $sth->fetchrow_array()){
				if($en{$result}){
					print STDERR "ExcludedB: $input"; $txn{$taxidorg}='fake';
					next OUTER;
				}elsif($er{$result}){
					print STDERR "UnclassifiedB: $input"; $txn{$taxidorg}='unknown';
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
				print STDERR "UnclassifiedC: $input";
				$txn{$taxidorg}='unknown'; #unclassified: 'unkown' to ignore, OR comment this line to leave as 'other'
				next OUTER; 
			}
		}
	}
}
$dbh->disconnect();

undef $taxid;
foreach $taxid(sort keys %txn){
	print $taxid, " ", $txn{$taxid}, "\n";
}
print "\#\#\#LineageEnd\n"; #for lineage2table.pl

sub USAGE{
	print STDERR "You must provide one(only one) input file. \nUsage:\n";
	print STDERR "perl $0 [-ex exclude_taxID_file] *.taxid >output.lin\n";
	print STDERR "Option '-ex' is optional, omit it if you have nothing to exclude.\n";
	exit 0;
}
=pod input: last col is taxid(no col limit, all taxid appended after " "):
scaffold0_1039137..1039572	260184420	2e-25	125	3218
scaffold0_1039137..1039572	261362271	1e-21	113	81964
=cut