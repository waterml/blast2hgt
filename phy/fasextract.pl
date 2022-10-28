#!/usr/bin/perl -w
#only store seq of matched id, to reduce memory usage

die "usage: perl $0 [seq_file] [id_file]\n" unless $ARGV[1];
open IDF, "$ARGV[1]" or die "Fail_to_open $! \n";
while (<IDF>) {
	chomp; next if /^\s+/; 
	s/ .*//; s/>//;
	$hit{$_}=1;
	push @order, $_;
}
close IDF;
$/="\n>";
open SEQ, "$ARGV[0]" or die "Failed_to_open $ARGV[0] : $! \n"; #seq_file
while (<SEQ>) {
	s/\>//mg;
	$id=$_; $id=~s/\n.*//mg; $id=~s/ .*//mg; #use firt line as id, and trim space.*
	s/\n\n/\n/mg; #remve dupicated "\n"
	if($hit{$id}){
		if ((/\n[A-Z]/) || (/\n[a-z]/)) { #skip if ID with empty seq in SEQ file
			$gotseq{$id}='>'.$_; #store to hash
		}else{print STDERR "Found_ID_without_Seq, ignore: $id\n";}
	}
}
foreach $idg(@order){ #print according to order
	if ($gotseq{$idg}){
		print $gotseq{$idg};
	}else{
			print STDERR "Not_Found: $idg\n";
	}
}
