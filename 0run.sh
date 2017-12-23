#!/bin/sh

dirpath=$PWD
query=human51.fa
cat $query\_rpd.*.dbls >$query\_rpd.dbls.all
awk '$11<=1e-5{print $1,$2,$11,$12}' $query\_rpd.dbls.all |
perl -pe 's/ /\t/g;' >$query.rp.blsraw
perl $dirpath/bin/blast_mine_maxb.pl $query.rp.blsraw >$query.rp.bls
perl $dirpath/bin/accgi_refseqProtein2taxonid.pl $query.rp.bls >$query.rp.taxid
perl $dirpath/bin/taxonid2lineage3.pl $query.rp.taxid >$query.rp.lin
perl $dirpath/bin/lineage2table3.pub.pl --define Metazoa=33208 \
--define Plant=33090 \
--define archaea=2157 \
--define bacteria=2 \
--define fungi=4751 \
--define virus=10239 \
$query.rp.lin >$query.rp.tsv
