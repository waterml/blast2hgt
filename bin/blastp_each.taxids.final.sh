#!/bin/sh
#blastp the given fasta against split nr database
if [ $# -eq 0 ];then echo No query provided;exit;fi
# for part in 10239 136087 1401294 193537 207245 2157 2763 28009 2830 2 3027 33090 33208 33630 33634 33682 339960 38254 42452 42461 4751 543769 554296 554915 556282 5719 5752 66288;do
for part in 4527 33090 33208 33630 33634 33682 339960 38254 42452 42461 4751 543769 554296 554915 556282 5719 5752 66288;do
        if [ -s /home/lm/tools/blast2hgt/species_taxids/$part.txids ];then #skip empty taxids
                blastp -db ~/ncbi/nr/nr -query $1 -taxidlist /home/lm/tools/blast2hgt/species_taxids/$part.txids -outfmt 6 -max_target_seqs 1000 -evalue 0.1 -num_threads 28 -out $1.$part.nr.blastpout
        fi
echo `date` $1 - $part blastp DONE.
done
