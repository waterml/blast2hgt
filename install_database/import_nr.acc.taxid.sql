\! echo 'Loading nr.acc.taxid.lite, this can take a very long time'

DROP TABLE IF EXISTS `nr_acc_taxid`; #edit, use replace 1
CREATE TABLE `nr_acc_taxid` (
	`accession` varchar(255) NOT NULL default '',
	`taxid` int(10) unsigned default NULL,
	PRIMARY KEY `accession` (`accession`),
	KEY `taxid` (`taxid`)
)ENGINE=MyISAM DEFAULT CHARSET=latin1;

set autocommit = 0; #speedup
LOAD DATA LOCAL INFILE 'nr.acc.taxid.lite' #edit, use replace 2
	INTO TABLE nr_acc_taxid
	FIELDS TERMINATED BY ' '
	LINES TERMINATED BY '\n'
	IGNORE 0 LINES #ignore col_header, NA for nr.acc.taxid
	(accession,taxid);
commit;

