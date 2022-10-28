#!/usr/bin/perl -w
#read representives.txt and classify *.lin. 
#get n seqs based on subgroups hit's num(%).
#updates are put in lineage2idgroup3.batch.pl
#recommand use: lineage2idgroup3.batch.pl
use Scalar::Util qw(looks_like_number);
die "usage: perl $0 [representatives.txt] [*.lineage] [id]\nOutput_to id.org\n" unless $ARGV[2];

$id_name=$ARGV[2]; chomp($id_name); $ids{$id_name}=1; #to consist with lineage2idgroup3.batch.pl
#below should be same as lineage2idgroup3.batch.pl
print STDERR "Target_IDs: ", join(' ', sort keys %ids),"\n";

open GR, "$ARGV[0]" or die "FailToOpen $ARGV[0]\n"; #read groups from representives.txt
while(<GR>){ #read groups into hash
	next if /^\#|^$/;
	chomp;
	if (/^self/){
		@ar=split /\t/;
		$tax{$ar[2]}=$ar[1];
		$tax_in_self{$ar[1]}=$ar[2];
		$selftax=$ar[1]; #only one self in representives.txt allowed
	}elsif(/^\&/){ #this is a header
		$groupname=$_; $groupname=~s/^.*\t//; $groupname=~s/ /\_/;
		$taxnum=$_;$taxnum=~s/\t.*//g;$taxnum=~s/\&//;
		$tax2nd{$groupname}=$taxnum if($groupname !~/\_sis/);
	}else{
		s/ /_/g; #sub groupname may contain ' ', replace to '_'
		my @ar=split /\t/;
		if($groupname !~/\_sis/){ #not add header to *_sis: fungi_sis..plant_sis;
			$ar[1]=$groupname.'-'.$ar[1]; #append groupname to subgroup name
		}
		$tax{$ar[1]}=$ar[0];
	}
}
close GR;

$inputf=1;
open LN, "$ARGV[1]" or die "FailToOpen $ARGV[1]\n"; #classify lineage to group
LINE: while (<LN>) {
	if (/LineageEnd/){
		$inputf=0;
		print STDERR "DONE_reading_lineage, begin_reading_blastout\n";
		next;
	}
	chomp;
	if($inputf==1){ #these lines are lineage, put them to hash
		$txn=$_; $txn=~s/ .*//; #$txn is a taxid, 1st col of lin
		s/^/ /; #add \s 
		if (/\s+28384\s+|\s+12908\s+|\s+1678845\s+/){ #skip fake/unclassified taxonomy
			$tatxn{$txn}='fake';
		}elsif(/\s+$selftax\s+|^$selftax\s+/){ #tax within self, get each seq per species
			$tatxn{$txn}=$tax_in_self{$selftax}.'.'.$txn;#append tax_id to self end
			# print STDERR $tatxn{$txn}."\n";
		}else{
			foreach my $subgroupname (sort keys %tax){ #sort is mandatory, random hash_order
				if (/\s+$tax{$subgroupname}\s+/){ #assign group(in %tax) to $txn
					$tatxn{$txn}=$subgroupname;
					next LINE;
				}
			}
			foreach my $topgroup (sort keys %tax2nd){ #when subgroup not listed, use group
				if (/\s+$tax2nd{$topgroup}\s+/){ #assign group(in %tax2nd) to $txn
					$tatxn{$txn}=$topgroup;
					next LINE;
				}
			}
		}
	}else{ #these lines are blastout
		if(/\t.*?\t.*\t/){ ##1. standard *.lin
			my $if=$_;$if=~s/\t.*$//; next unless $ids{$if}; #next if seq not in id_file
			my @arr=split /\t/; undef $group;
			unless(looks_like_number($arr[2])&&looks_like_number($arr[3])&&looks_like_number($arr[4])){
				print STDERR "Line $. Error: $_\n"; next;
			}
			if(exists $tatxn{$arr[$#arr]}){ #1.1. with a lineage, classify to %tax
				next if $tatxn{$arr[$#arr]} eq 'fake';
				my $group=$tatxn{$arr[$#arr]}; #this is sub group name
				###only use bitscore>=100###############################################
				# if ($arr[3] >= 100){
				if ($arr[2] <= 10){ #edit if need more strict citeria
					$acce=$arr[1];
					$acce=~s/\..*//; #remove \. if needed
					push @{$ha{$arr[0]}{$group}{$arr[3]}}, $acce unless $got{$arr[0]}{$acce};
					$got{$arr[0]}{$acce}=1; #mark acce as got
					$species_acc{$acce}=$arr[$#arr]; #mark species on acc, no need differentiate hits
					if($count{$arr[0]}{$group}){$count{$arr[0]}{$group}+=1;}else{$count{$arr[0]}{$group}=1;}
					# $arr[3] is bitscore, eachtaxid - each bitscore = each acc
				}else{ #mark as no hits when E/bit not meet cutoff
					$un{$arr[0]}=1;
				}
			}
		}elsif(/^.*?\t.*?$/){ ##2. two cols(not *.lin), join with group info then print directly
			my @arr=split /\t/; undef $group;
			if(exists $tatxn{$arr[$#arr]}){ #2.1.with a lineage, classify to %tax
				next if $tatxn{$arr[$#arr]} eq 'fake';
				$group=$tatxn{$arr[$#arr]};
				$acce=$arr[0]; $acce=~s/\..*//;
				print "$group $acce\n";
			}
		}
	}
}
close LN;

print STDERR "Getting_seq_list_for: ", join(' ', sort keys %ha),"\n";
foreach $seqid(sort keys %ha){
	open OUT, ">$seqid.id.org";
	undef my %dup; undef my @gn; @gn=sort keys %{$ha{$seqid}}; #subgroups names
	delete $un{$seqid} if $un{$seqid}; #remove a sub group from %un once been get
	print OUT "self $seqid\n";
	foreach my $subgroup (sort keys %{$ha{$seqid}}){
		my ($gp, $num)=(); undef my @bit; undef my %alreadygotcount;
		$gp=$subgroup;
		@bit=sort{$a <=> $b} keys %{$ha{$seqid}{$subgroup}}; #ascending bitscore
		###No. of seqs each subgroup##############################################
		$num=$count{$seqid}{$subgroup};
		# $num=scalar(@bit)*0.8; #get 80% hits; same bitscore only count 1
		$num=10 if $num >10; #at most get 10 seqs per non-self subgroup
		# $num=1 if $gp =~/^$tax_in_self{$selftax}/i; #self (within self tax) get 1 seq
		#Note_on_above_line: average Bitscore(self) from here may not eq that from lineage2table.meanBitscore.pl, because one more top seqs may from same self tax.
		$n=1;while($n<=$num){ #decide how many seqs kept per subgroup
			if ($eachbit=pop @bit){
				foreach $target(@{$ha{$seqid}{$subgroup}{$eachbit}}){
					last if $n>$num; #sometime should parts from array
					unless($alreadygotcount{$species_acc{$target}}) { #one seq per species
						unless($dup{$target}){
							print OUT $gp, " ", "$target $eachbit\n";
							$dup{$target}=1; #must reset when seqid changed
							$alreadygotcount{$species_acc{$target}}=1;
							$n++;
						}
					}
				}
			}else{
				last;
			}
		}
	}
	close OUT;
}
if (%un){ #if have previous output, here print nothing
	print STDERR join(" has_no_homolog_because_no_Bit/E_meet_citeria\n", keys %un);
	print STDERR " has_no_homolog_because_no_Bit/E_meet_citeria\n";
}
