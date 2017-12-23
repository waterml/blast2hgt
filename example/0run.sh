#!/bin/sh

exepath=/home/peg/tools/hgtpub/bin
query=rh.best.6p.fa

cat $query\_rp.*.blastout >$query\_rpd.dbls.all

awk '$11<=1e-5{print $1,$2,$11,$12}' $query\_rpd.dbls.all |perl -pe 's/ /\t/g;' >$query.rp.bls
###if blast hit format like: gi|552917951|gb|ESA02932.1|
#awk '$11<=1e-5{print $1,$2,$11,$12}' |perl -pe 's/ gi\|.*?\|.*?\|/ /;s/\|//;s/ /\t/g;' >$query.rp.bls
###

perl $exepath/accgi_refseqProtein2taxonid.pl $query.rp.bls >$query.rp.taxid

perl $exepath/taxonid2lineage3.pub.pl $query.rp.taxid >$query.rp.lin

cat $query.rp.lin $query.rp.taxid |perl $exepath/lineage2table3.pub.pl - --define fungi=4751 \
--define Plant=33090 \
--define archaea=2157 \
--define bacteria=2 \
--define Metazoa=33208 \
--define virus=10239 \
--define Rhodophyta=2763 \
--define Glaucocystophyceae=38254 \
>$query.rp.tsv
