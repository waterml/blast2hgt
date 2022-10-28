#!/bin/sh
# use get_species_taxids.pl to get taxids under a given group

#Tips: 1001604 12884 were removed by ncbi, 610163 was environ sample, they should not be used as a group in subsequent analysis.
#These taxids (in next line) should be chosen according to your study design.
for n in 1001604 10239 12884 136087 1401294 193537 2 207245 2157 2763 28009 2830 3027 33090 33208 33630 33634 33682 339960 38254 42452 42461 4751 543769 554296 554915 556282 5719 5752 610163 66288;do
#for n in 2763; do #red algae (green algae is in 33090)
	perl get_species_taxids.pl $n >$n.txids
	# Optionally, you can run 'get_species_taxids.sh' (officially released by NCBI) to get the SAME results (*.txids).
	#get_species_taxids.sh -t $n >$n.txids
done
echo DONE get_species_taxids.pl

