#mysql -u root -p
#CREATE DATABASE taxondb;
#GRANT ALL ON taxondb.* TO 'test'@'localhost' IDENTIFIED BY '1234';
#GRANT ALL ON taxondb.* TO 'test'@'%' IDENTIFIED BY '1234';
#QUIT;

#mysql --local-infile -hlocalhost -uroot taxondb -p222222 < import_gi_taxid_nucl.sql
#mysql --local-infile -hlocalhost -uroot taxnode -plab2016 --default-character-set=utf8 < import_nodes.sql
#echo import_nodes.sql done
#mysql --local-infile -hlocalhost -uroot taxondb -plab2016 <import_nucl_gb.accession2taxid.sql
#echo import_nucl_gb.accession2taxid.sql done
mysql --local-infile -hlocalhost -uroot taxondb -plab2016 <import_prot.accession2taxid.sql
echo import_prot.accession2taxid.sql done

