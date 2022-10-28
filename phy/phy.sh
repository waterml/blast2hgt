#!/bin/sh

if [ "$#" -lt 1 ];then echo NoInput;exit;fi
n=$1
name=${n%%.fa}

echo Now $name
echo 'BEGIN mafft'
mafft --auto --anysymbol --quiet --thread -1 $name.fa >$name.fa.aln && \
trimal -gt 0.3 -in $name.fa.aln -out $name.fa.aln.tr

echo 'BEGIN tree'
iqtree -nt AUTO -m TEST -bb 1000 -alrt 1000 -s $name.fa.aln.tr && \
mv $name.fa.aln.tr.contree $name.nwk && \
rm $name.fa.aln.tr.*

