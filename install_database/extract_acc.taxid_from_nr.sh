#!/bin/sh

db=nr
#blastdbcmd -db ~/ncbi/nr/nr -entry all -outfmt "%a %T" >nr.acc.taxid
##blastdbcmd -db ~/ncbi/nr/nr -entry all -outfmt "%a %T %g" >nr.acc.taxid.gi
perl -pe 's/\..*? / /' $db.acc.taxid |grep -v -e '=' -e ',' |sort --parallel=20 |uniq >$db.acc.taxid.lite
