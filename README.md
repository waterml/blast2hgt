Blast2hgt
------
Determine horizontal transfer candidates based on sequence similarity. Currently supports BLAST outputs.    
The targets can be proteins, genes or partitial genomic sequences.   

**Note:** A nuclear database is required for horizontal transfered genes/nucleotide sequences;   
And a protein database is required for horizontal transfered proteins;   
Do not mix them.

**How to install:**  
All files are portable.   
However, a database with a table containing hits' accession && species taxonomy ID as well as a table of NCBI taxonomy map is mandatory.  
The first table can be constructed from `gi_taxid_prot.zip/gi_taxid_nucl.zip` or built from `nr/nt`;     
The second table can be constructed from `taxdump.tar.gz`.   
Above files can be downloaded from NCBI website: ftp://ftp.ncbi.nih.gov/pub/taxonomy/.   
See `INSTALL` for detailed database installation guide. 

**How to run:**  
`0run.sh` contains a simple example explaining how to run Blast2hgt.   
