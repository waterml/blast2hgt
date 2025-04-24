\! echo 'Loading nucl_gb.accession2taxid - this can take a very long time'
DROP TABLE IF EXISTS `nucl_gb_accession2taxid`;
CREATE TABLE `nucl_gb_accession2taxid` (
	`accession` varchar(255) NOT NULL default '',
	`acc_version` varchar(255) NOT NULL default '',
	`taxid` int(10) unsigned default NULL,
	`gi` int(10) unsigned default NULL,
	PRIMARY KEY `accession` (`accession`),
	KEY `gi` (`gi`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

set autocommit = 0; #speedup
LOAD DATA LOCAL INFILE '/home/peg/tools/gi2taxid/nucl_gb.accession2taxid'
	INTO TABLE nucl_gb_accession2taxid
	FIELDS TERMINATED BY '\t'
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES #igore col_header
	(accession,acc_version,taxid,gi);
commit;

