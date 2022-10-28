SET @table_name := 'nr_acc_taxid';
SET @inputfile_name := 'nr.acc.taxid.lite';
SELECT @table_name; #print to screen
SELECT @inputfile_name;
\! echo 'Loading, this can take a very long time'

SET @sql_text1 = concat('DROP TABLE IF EXISTS ', @table_name);
PREPARE stmt1 FROM @sql_text1;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

SET @sql_text2 = concat('CREATE TABLE ', @table_name, " (`accession` varchar(255) NOT NULL default '',	`taxid` int(10) unsigned default NULL, PRIMARY KEY `accession` (`accession`), KEY `taxid` (`taxid`)) ENGINE=MyISAM DEFAULT CHARSET=latin1");
PREPARE stmt2 FROM @sql_text2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

set autocommit = 0; #speedup
LOAD DATA LOCAL INFILE 'nr.acc.taxid.lite'
	INTO TABLE nr_acc_taxid
	FIELDS TERMINATED BY ' '
	LINES TERMINATED BY '\n'
	IGNORE 0 LINES #ignore col_header, NA for nr.acc.taxid
	(accession,taxid);
commit;

