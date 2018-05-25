#!/bin/sh

#In beblow steps, it supposes that "~/ncbidb/refseq_protein170410/refseq_protein" is the BLAST database
##1 get all acc number from NR/refseq:
blastdbcmd -db ~/ncbidb/refseq_protein170410/refseq_protein -entry all -outfmt "%a %T %g" >allrp.acc.taxid.gi

##2 minor tweaks, may skip this step:
perl -pe 's/\..*? / /' allrp.acc.taxid.gi |grep -v -e '=' -e ',' |sort --parallel=4 |uniq >allrp.acc.taxid.gi.lite

##3 extract accs for each groups listed in "group.txt"
###use "allrp.acc.taxid.gi" as input if step 2 was skipped
###this step would produce *.acc for items listed in "group.txt"
perl ncbi_acc2groupbatch.pl allrp.acc.taxid.gi.lite group.txt 

##4 create BLAST databases for *.acc
### "1001604 10239 ..." are items listed in "group.txt"
for n in 1001604 10239 12884 136087 1401294 193537 2 207245 2157 2763 28009 2830 3027 33090 33208 33630 33634 33682 339960 38254 42452 42461 4751 543769 554296 554915 556282 5719 5752 610163 66288;do 
if [ ! -f $n.acc ];then echo $n.acc Not_exists;continue;fi
blastdb_aliastool -seqidlist $n.acc -dbtype prot -db ~/ncbidb/refseq_protein170410/refseq_protein -out $n.acc
done
echo DONE blastdb_aliastool

