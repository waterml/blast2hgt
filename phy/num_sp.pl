#!/usr/bin/env perl -w
#how many groups keep (from *.id.org), this is not subgroups
#will skip these subgroups hits whose bitscore < $b of last group
while (<>) {
	if(/self|glomeromycetes/){
		print;next;
	}else{
		chomp;
		if(/\-/){
			$group=$_;$group=~s/\-.*//;
			$sub=$_; $sub=~s/^.*\-//;$sub=~s/ .*//;
		}else{
			$group=$_;$group=~s/ .*//;
			$sub='xxx';
		}
		$bit=$_;$bit=~s/^.* //;
		$ha{$group}{$sub}=$bit unless ($ha{$group}{$sub} && $ha{$group}{$sub}>$bit);
		push @{$ta{$group}{$sub}}, $_;
	}
}
foreach (keys %ha){
	push @max, values %{$ha{$_}};
}
@max=sort{$a<=>$b} @max;
print STDERR join(' ', @max), "\n";

$num = 5; # how many groups (not subgroups): ###############################
### $num including self's group, eg. fungi -rh
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
print STDERR "Minimum_bitscore: $b $gl $sl\n";

while (@can) { 
	$item=pop @can;
	print "$item\n";
	#Below Removed(because donor_group sometimes be trimed to 1): skip whose bitscore < $b of last group
	# if($item=~/\-/){ #has sub
	# 	$gg=$item; $gg=~s/\-.*//;$gg=~s/ .*//;
	# 	$ss=$item; $ss=~s/^.*?\-//;$ss=~s/ .*//;
	# }else{ #sub is xxx
	# 	$gg=$item; $gg=~s/ .*//;
	# 	$ss='xxx';
	# }
	# print STDERR "$gg $ss\n";

	# $bitscore=$item; $bitscore=~s/^.* //;
	# if($gg eq $gl && $ss eq $sl){ #last group, $b is the max of their bit
	# 	print "$item\n";
	# }else{
	# 	print "$item\n" if $bitscore >= $b; #allow low to $b
	# }
}
