#!/bin/bash
export PATH=$PATH:/home/lm/tools/mariadb-11.4.5-linux-systemd-x86_64/bin

###Should run this script only when mariadbd daemon is running. To start:
###mariadbd-safe --defaults-file=/home/lm/tools/blast2hgt/mariadb_data/my.cnf --no-auto-restart
###To shutdown: mariadb-admin --defaults-file=/home/lm/tools/blast2hgt/mariadb_data/my.cnf shutdown

###Below add test(with password:1234) to Mysql users;
###Alternatively you can custom the username and password, 
###but you need to change these info in 'accgi_nr2taxonid.pl', 'accgi_refseqProtein2taxonid.pl', 'taxonid2lineage3.pub.pl' and 'taxonid2lineage3.pl' accordingly.

user=test;
password=1234;
#mysql -u root -p
#CREATE DATABASE taxondb;
#GRANT ALL ON taxondb.* TO 'test'@'localhost' IDENTIFIED BY '1234';
#GRANT ALL ON taxondb.* TO 'test'@'%' IDENTIFIED BY '1234';
#QUIT;

#mysql --local-infile -hlocalhost -u$user taxondb -p$password < import_gi_taxid_nucl.sql
#mysql --local-infile -hlocalhost -u$user taxondb -p$password <import_nucl_gb.accession2taxid.sql
#echo import_nucl_gb.accession2taxid.sql done
#mysql --local-infile -hlocalhost -u$user taxondb -p$password <import_prot.accession2taxid.sql

#below is used 202504:
#mariadb --defaults-file=/home/lm/tools/blast2hgt/mariadb_data/my.cnf --local-infile -hlocalhost -u$user taxonnode -p$password --default-character-set=utf8 < import_nodes.sql
#echo import_nodes.sql done
#mariadb --defaults-file=/home/lm/tools/blast2hgt/mariadb_data/my.cnf --local-infile -hlocalhost -u$user taxondb -p$password <import_nr.acc.taxid.sql
#echo DONE 
mariadb --defaults-file=/home/lm/tools/blast2hgt/mariadb_data/my.cnf --local-infile -hlocalhost -u$user taxondb -p$password <import_nt.acc.taxid.sql && echo import_nt.acc.taxid.sql_DONE
