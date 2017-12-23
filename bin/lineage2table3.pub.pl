#!/usr/bin/perl -w
#perl $0 [*.lineage] --define self=4751 --define plant=33090 --define virus=10239 >out

use Getopt::Long;
use Tie::IxHash;
use Scalar::Util qw(looks_like_number);

tie %define, 'Tie::IxHash';
GetOptions ("define=s" => \%define);
&USAGE unless (scalar(keys %define) >=2) && $#ARGV==0;
print STDERR "Target taxonomy:\n";
my @orders=(AAAA, BBBB..BBEZ); #up to 102
foreach (keys %define){
	$order=shift @orders;
	$tax{$order}=$define{$_}; # %tax For classify the blastout
}
%def=reverse %define; # %def: 2-bac, 4751-fungi ...
$def{'other'}='other'; #other dont has a taxid, assign 'other'
####On screen what is doing
foreach (sort keys %tax){ 
	print STDERR $_,' ',$tax{$_},' ', $def{$tax{$_}},"\n";
}
print STDERR "Careful about the order, stop if wrong.\n";
####

%taxd=%tax; #true donor groups(no AAAA, has other)
delete $taxd{'AAAA'}; $taxd{'other'}='other';
my @donor=sort keys %taxd;

####create table header
foreach(sort keys %taxd){ 
	push @donorsorted, $def{$taxd{$_}};
}
$donorprint=join ("\t", @donorsorted);
$donorprint=uc $donorprint;
####

$inputf=1;
open LIN, "$ARGV[0]" or die "ERROR_Opening $ARGV[0]: $!\n";
while(<LIN>){ #classify the groups
	if (/LineageEnd/){
		$inputf=0; print STDERR "DONE_reading_lineage\n"; next;
	}
	chomp;
	if($inputf==1){ #put lineage to hash
		$taxid_initial=$_; $taxid_initial=~s/ .*//;
		if(/fake|unknown/i){
			$tatxn{$taxid_initial}='fake'; next;
		}
		s/^/ /; #add \s 
		LINE: foreach my $groupx (sort keys %tax){ #%tax{AAAA=>4751, BBBB=>2}
			if (/\s+$tax{$groupx}\s+/){ #assign group(in %tax) to $taxid_initial
				$tatxn{$taxid_initial}=$groupx;
				last LINE;
			}
		}
	} else { #now read blastout '9999	762083944	2e-08	65.5	29159'
		my @arr=split /\t/;
		unless(looks_like_number($arr[2])&&looks_like_number($arr[3])&&looks_like_number($arr[4])){
			print STDERR "Skip ErrorLine $. : $_\n";
			next;
		}
		undef $sp;
		if(exists $tatxn{$arr[$#arr]}){ #1.with a lineage, classify to %tax
			next if $tatxn{$arr[$#arr]} eq 'fake';
			$sp=$tatxn{$arr[$#arr]};
		}else{ #2.taxid no special lineage: other
			$sp='other';
		}
		unless((exists $tae{$arr[0]}{$sp})&&($tae{$arr[0]}{$sp}<=$arr[2])){
			$tae{$arr[0]}{$sp}=$arr[2];
		}
		unless((exists $tab{$arr[0]}{$sp})&&($tab{$arr[0]}{$sp}>=$arr[3])){
			my $bin=sprintf("%.2f", $arr[3]);
			$tab{$arr[0]}{$sp}=$bin;
		}
		$count{$arr[0]}{$sp}{$arr[$#arr]}=1 if $arr[$#arr-2]<=1e-5;
		# $count{$arr[0]}{$sp}{$arr[$#arr]}=1 if $arr[$#arr-1]>=100; #count group(except AAAA)'s taxon num, bitscore >=100 counts.
	}
}
close LIN;
print STDERR "DONE_reading_blastout ", scalar localtime, "\n";

print "#Query_id\tE_self\t";
print $donorprint;
print "\talien_index\tAI_taxon\tBits_self\t";
print $donorprint;
print "\tBit_Diff\t\%Bit_Diff\tBitRatio\th_taxon";
print "\tDonorBitscore\tDonorTaxonNO\n";

foreach (sort keys %tae){
	undef @bscnd;
	undef @escnd;
	foreach my $nam(sort keys %tax, 'other'){ #assign a value if they are null
		$tae{$_}{$nam}=1 unless exists $tae{$_}{$nam};
		$tab{$_}{$nam}=0 unless exists $tab{$_}{$nam};
		if($nam ne 'AAAA'){ #donor's E H don't contain self
			push @escnd, $tae{$_}{$nam};
			push @bscnd, $tab{$_}{$nam}; #including group_vertical, donors(also other)
		}
	}
	@escnd=sort {$a <=> $b} @escnd;
	@bscnd=sort {$a <=> $b} @bscnd;
#AI:
	my $myai=calAI($escnd[1], $escnd[0]);
#$bdiff(h), $bitdp(%diff), $bratio:
	my $bdiff=sprintf("%.2f", $bscnd[$#bscnd] - $bscnd[($#bscnd-1)]);
	$bitdp=DiffPercent($bscnd[$#bscnd], $bscnd[($#bscnd-1)]);
	if($bscnd[($#bscnd-1)] != 0){ #avoid illegal division by 0
		$bratio=sprintf("%.2f", ($bscnd[$#bscnd] / $bscnd[($#bscnd-1)]));
	} else {
		$bratio=$bscnd[$#bscnd];
	}
	print $_;
#print Evalues:
#Evalue=1 is confusing to human, replace by '-'
	if($tae{$_}{'AAAA'}==1){ print "\t\-";}else{ print "\t$tae{$_}{'AAAA'}";}
	my ($efrom, $bfrom)=('unknown', 'unknown'); #default from_species
	foreach $name(@donor){
		$efrom=$def{$taxd{$name}} if ($escnd[0]==$tae{$_}{$name} && $myai>0);
		if($tae{$_}{$name}==1){ print "\t\-";}else{ print "\t$tae{$_}{$name}";}
	}
	print "\t$myai\t$efrom";
	if($tab{$_}{'AAAA'}==0){ print "\t\-";}else{ print "\t$tab{$_}{'AAAA'}";}
#print bitscores:
#bitscore=0 is confusing to human, replace by '-'
	foreach $name(@donor){
		if ($bscnd[$#bscnd]==$tab{$_}{$name} && $bdiff>0){$bfrom=$def{$taxd{$name}}; $bfromB=$name;}
		if($tab{$_}{$name}==0){ print "\t\-";}else{ print "\t$tab{$_}{$name}";}
	}
	if($bfromB){ #unknown no count info
		$donortaxonNO=scalar(keys %{$count{$_}{$bfromB}});
		}else{$donortaxonNO=0;print STDERR "$_\n;"}
	print "\t$bdiff\t$bitdp\t$bratio\t$bfrom";
	print "\t$bscnd[$#bscnd]\t$donortaxonNO";
	print "\n";
}

sub calAI {
	my $ai = log($_[0] + 1e-200) - log($_[1] + 1e-200);
	$ai=sprintf("%.2f", $ai);
	return $ai;
}
sub DiffPercent {
	if(($_[0] + $_[1]) != 0){ 
	#avoid illegal division by 0. Sometimes all donor's no hit, $_[0], $_[1] are 0;
		$diff=($_[0] - $_[1])*200 / ($_[0] + $_[1]);
	} else {
		$diff=$_[0];
	}
	$diff=sprintf("%.2f", $diff);
	return $diff;
}
sub USAGE{
	print STDERR "Usage: 
perl $0 .lin --define groupSELF=taxonID_SELF --define groupA=taxonID_groupA ... >out
groupSELF AND at_least 1 donorgroup(groupA) are mandatory. groupSELF/donorgroup can be a group of species or a single species. More donorgroups are allowed.
Firstly defined group will be treated as self group.
e.g.:
perl $0 input.lin --define fungi=4751 --define bacteria=2 --define virus=10239 >out
Will treat fungi(with taxonId 4751) as self group, get hgts from/to bacteria(2) and virus(10239) to/from fungi.\n";
	exit 0;
}
