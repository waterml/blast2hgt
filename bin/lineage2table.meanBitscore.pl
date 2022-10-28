#!/usr/bin/perl -w
#updated:2020.12.15
#perl $0 [*.lineage] --define fungi=4751 --define plant=33090 --define virus=10239 >out

use Getopt::Long;
use Tie::IxHash;
use Scalar::Util qw(looks_like_number);
use List::Util qw(max);

tie my %define, 'Tie::IxHash';
GetOptions ("define=s" => \%define, 
	"print=s" => \$preset_group); #In addition to AAAA, you may want print another group's seq No.
if ($preset_group){&USAGE unless looks_like_number($preset_group);} #--print 33090, Must be taxon_number
&USAGE unless (scalar(keys %define) >=2) && $#ARGV==0;
print STDERR "Target taxonomy:\n";
my @orders=(AAAA, BBBB..BBEZ); #up to 102
foreach (keys %define){
	my $order=shift @orders;
	$tax{$order}=$define{$_}; # %tax: AAAA-4751, BBBB-33090...
}
%def=reverse %define; # %def: 2-bac, 4751-fungi ...
$def{'other'}='other'; #other dont has a taxid, assign 'other'
%tax_rev=reverse %tax; #%tax_rev: 4751-AAAA, 33090-BBBB...
####On screen what is doing
foreach (sort keys %tax){ 
	print STDERR $_,' ',$tax{$_},' ', $def{$tax{$_}},"\n";
}
print STDERR "Careful about the order, stop if wrong.\n";
####

%taxd=%tax; #true donor groups(no AAAA, has other)
delete $taxd{'AAAA'}; $taxd{'other'}='other';

####create table header
foreach(sort keys %taxd){ 
	push @donorsorted, ucfirst lc $def{$taxd{$_}};
}
$donorprint=join ("\t", @donorsorted); @donorsorted=();
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
	} else { #now read blastout 'query99(Yourquery)	XP_1234(Hit)	2e-08	65.5	29159'
		my @arr=split /\t/;
		unless(looks_like_number($arr[2])&&looks_like_number($arr[3])&&looks_like_number($arr[4])){
			print STDERR "Skip ErrorLine $. : $_\n";
			next;
		}
		undef my $sp;
		if(exists $tatxn{$arr[$#arr]}){ #1.with a lineage, classify to %tax
			next if $tatxn{$arr[$#arr]} eq 'fake';
			$sp=$tatxn{$arr[$#arr]};
		}else{ #2.taxid no special lineage: other
			$sp='other';
		}
		my $bin=sprintf("%.2f", $arr[3]);
		push @{$tab{$arr[0]}{$sp}}, $bin;
		$count{$arr[0]}{$sp}{$arr[$#arr]}=1;
		# $count{$arr[0]}{$sp}{$arr[$#arr]}=1 if $arr[$#arr-2]<=1e-5; #TODO
		# $count{$arr[0]}{$sp}{$arr[$#arr]}=1 if $arr[$#arr-1]>=100; #count group(except AAAA)'s taxon num, bitscore >=100 counts.
	}
}
# print join("\n", values %tatxn);
close LIN;
print STDERR "DONE_reading_blastout ", scalar localtime, "\n";

print "#Query_id\t".$def{$tax{'AAAA'}}.'(self)'."\t";
print $donorprint;
print "\tBit_Diff\t\%Bit_Diff\tBitRatio\th_taxon";
print "\tDonorBitscore\tSeq.No\(Donor\)\tSeq.No\($def{$tax{'AAAA'}}\)";
print "\tSeq.No\($def{$tax{$tax_rev{$preset_group}}}\)" if $preset_group;
print "\n";

foreach my $query (sort keys %tab){
	undef my @bscnd; undef my @group;
	foreach my $group('AAAA', sort keys %taxd){ #calc mean of top n bitscores
		undef my $sum;
		if($tab{$query}{$group}){
			my @bitEachGroup= sort {$a <=> $b} @{$tab{$query}{$group}};
			my $n=0;while(@bitEachGroup){ #Instead of the best bitscore, get the top 5 of them
				$sum += pop @bitEachGroup;
				$n++; last if $n>=5;
			}
			$bit_mean{$query}{$group}=sprintf("%.2f", $sum/$n);
		}else{ #no hit in this group
			$bit_mean{$query}{$group}=0;
		}
	}
	my $bit_Self_mean=delete $bit_mean{$query}{'AAAA'}; #delete && give bit(AAAA) to $bit_Self_mean
	@bscnd=values %{$bit_mean{$query}}; # %bit_mean has no AAAA, but only donors
	@bscnd=sort {$a <=> $b} @bscnd;
#$bdiff(h), $bitdp(%diff), $bratio:
	my $bdiff=sprintf("%.2f", $bscnd[$#bscnd] - $bscnd[($#bscnd-1)]);
	$bitdp=DiffPercent($bscnd[$#bscnd], $bscnd[($#bscnd-1)]);
	if($bscnd[($#bscnd-1)] != 0){ #avoid illegal division by 0
		$bratio=sprintf("%.2f", ($bscnd[$#bscnd] / $bscnd[($#bscnd-1)]));
	} else {
		$bratio=$bscnd[$#bscnd];
	}
	print $query;
#bitscore=0 is confusing to human, replace by '-'
	# my $bitSelf=max @{$tab{$query}{'AAAA'}};
	if($bit_Self_mean && ($bit_Self_mean != 0)){ print "\t", $bit_Self_mean;}else{ print "\t\-";}
	my ($bfrom, $donortaxonNO)=('NA', 'NA');
	foreach my $group(sort keys %taxd){
		if ($bscnd[$#bscnd]==$bit_mean{$query}{$group} && $bdiff>0){
			$bfrom=$def{$taxd{$group}};
			$donortaxonNO=scalar(keys %{$count{$query}{$group}});
		}
		if($bit_mean{$query}{$group}==0){ print "\t\-";}else{ print "\t$bit_mean{$query}{$group}";}
	}
	print "\t$bdiff\t$bitdp\t$bratio\t$bfrom";
	print "\t$bscnd[$#bscnd]\t$donortaxonNO";
	print "\t", scalar(keys %{$count{$query}{'AAAA'}});
	print "\t", scalar(keys %{$count{$query}{$tax_rev{$preset_group}}}) if $preset_group;; 
	print "\n";
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
perl $0 [*.lin] --define groupSELF=taxonID_SELF --define groupA=taxonID_groupA ... >out
groupSELF(recipient) and at least 1 donorgroup are mandatory. They can be a group of species or a single species.
The primarily defined group will be treated as self(recipient) group:
perl $0 input.lin --define fungi=4751 --define bacteria=2 --define virus=10239 >out
Will treat fungi(taxonId 4751) as self(recipient) group, get HTs from bacteria(2) or virus(10239) to fungi.\n";
	exit 0;
}
