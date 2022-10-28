#!/usr/bin/perl -w
#perl $0 [blastcmdOutFa] [acclist from lineage2idgroup2.pl]
open FA, "$ARGV[0]";
while(<FA>){
	chomp;
	if(/^\>/){
		s/\>//;
		# s/^.*?\|.*?\|.*?\|//; #format ncbi raw id name
		s/ .*//g;
		s/\..*//; #remove \. if needed
		$id=$_;
		$ta{$id} = []; #duplicated reset, see next_line
		@{$ta{$id}} = (); #duplicated reset, see previous_line
	}else{
		s/X//ig; #bad character
		push @{$ta{$id}}, $_;
	}
}
close FA;
open ACC, "$ARGV[1]";
while(<ACC>){
	chomp;
	$id=$_;
	# $id=~s/^.*? //; #remove seqid for each
	$id=~s/ /\./; #join 1st space to '.'
	$id=~s/ .*//; #only col1,2 used
	s/^.*? //;s/ .*//;
	if(exists $ta{$_}){
		print "\>$id\n";
		print @{$ta{$_}}, "\n";
		delete $ta{$_};
	}else{
		print STDERR "$id $_ NotFound\n";
	}
}
close ACC;
