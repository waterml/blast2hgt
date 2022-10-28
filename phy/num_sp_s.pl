#!/usr/bin/perl -w
#for build single id tree (debug), make sure update to num_sp.pl
#how many groups (desending from top hits) keep (from *.id.org), this is not subgroups
#Instead, seqs per subgroup was decided by lineage2idgroup3.pl
#will skip these subgroups hits whose bitscore < $b of last group
die "perl $0 [*.id.org] [HowManyTopGroups] >output \n" unless $ARGV[1];
open FH, "$ARGV[0]" or die "ErrorOpening $ARGV[0]\n";
while (<FH>) {
	if(/self/){
		#print; #do not print to .id.org
		next;
	}else{
		chomp;
		if(/\-/){
			$group=$_;$group=~s/\-.*//;
			$sub=$_; $sub=~s/^.*\-//;$sub=~s/ .*//;
		}else{ # *_sis, no sis, so $sub is $group
			#next if /incertae_sedis/; #may need skip 'incertae_sedis', not sure
			$group=$_;$group=~s/ .*//;
			$sub='Treat_subgroup_as_group';
		}
		$bit=$_;$bit=~s/^.* //;
		$ha{$group}{$sub}=$bit unless ($ha{$group}{$sub} && $ha{$group}{$sub}>$bit);
		push @{$ta{$group}{$sub}}, $_;
	}
}
close FH;
foreach (keys %ha){
	push @max, values %{$ha{$_}};
}
@max=sort{$a<=>$b} @max;
print STDERR join(' ', @max), "\n";

$num = $ARGV[1]; # how many groups (not subgroups): ###############################
### $num including self's group, eg. fungi - rh
LINE: while(@max){ #go down bitscore list until $num_groups get
	last LINE if scalar(keys %count) >= $num;
	$b=pop @max;
	foreach $g(sort keys %ha){
		foreach $s(sort keys %{$ha{$g}}){
			if ($ha{$g}{$s}==$b){
				if (@{$ta{$g}{$s}}){
					push @can, @{$ta{$g}{$s}};
					$count{$g}=1;
					@{$ta{$g}{$s}}=(); #avoid further re-use
					unless(@max){$gl=$g; $sl=$s;} #no more groups
					if(scalar(keys %count) == $num){$gl=$g; $sl=$s;} #reach $num groups
					next LINE;
				}
			}
		}
	}
}
print STDERR "$ARGV[0] - minimum_bitscore: $b $gl $sl\n" if ($b && $gl && $sl);

while (@can) { 
	$item=shift @can;
	print "$item\n";
}
