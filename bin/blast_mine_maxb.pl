#!/usr/bin/perl -w
#print min E and max bitscore for each query-hit pair
use Scalar::Util qw(looks_like_number);
while(<>){
	chomp;
	@ar=split /\t/;
	unless(looks_like_number($ar[2])&&looks_like_number($ar[3])){
		#skip/report lines with wrong format;
		print STDERR "Line $. Error: $_\n";
		next;
	}
	if ($tab{$ar[0]}{$ar[1]}){ #keep 1 max bitscore
		$tab{$ar[0]}{$ar[1]}=$ar[3] if $tab{$ar[0]}{$ar[1]}<$ar[3];
	}
	else{
		$tab{$ar[0]}{$ar[1]}=$ar[3];
	}
	if ($tae{$ar[0]}{$ar[1]}){ #keep 1 min E
		$tae{$ar[0]}{$ar[1]}=$ar[2] if $tae{$ar[0]}{$ar[1]}>$ar[2];
	}
	else{
		$tae{$ar[0]}{$ar[1]}=$ar[2];
	}
}
print STDERR "$0 DONE_reading_file ", scalar localtime, "\n";
foreach $id(sort keys %tab){
	foreach $hit(sort keys %{$tab{$id}}){
		print $id,"\t",$hit,"\t",$tae{$id}{$hit},"\t",$tab{$id}{$hit},"\n";
	}
}