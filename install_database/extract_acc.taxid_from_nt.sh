#!/bin/sh

db=nt
blastdbcmd -db ~/ncbi/nt20201013/$db -entry all -outfmt "%a %T" >$db.acc.taxid
##blastdbcmd -db ~/ncbi/nr/nr -entry all -outfmt "%a %T %g" >nr.acc.taxid.gi
perl -pe 's/\..*? / /' $db.acc.taxid |awk '$2!=0' |grep -v -e '=' -e ',' |sort --parallel=20 |uniq >$db.acc.taxid.lite
#above $2==0 is unidentified ORGANISM
