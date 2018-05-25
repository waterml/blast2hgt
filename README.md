Blast2hgt
------
Determine horizontal transfer candidates based on sequence similarity. Currently supports BLAST (or DIAMOND BLAST) outputs.    
The transfer targets can be proteins, genes or partitial genomic sequences.   

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

**For advanced user:**
Scripts and examples for BLAST database partition are stored in `BlastDB_split` folder.   

If you find this useful, please kindly cite:   
Li, M., Zhao, J., Tang, N., Sun, H., & Huang, J. (2018). Horizontal Gene Transfer From Bacteria and Plants to the Arbuscular Mycorrhizal Fungus Rhizophagus irregularis. Frontiers in Plant Science, 9, 701. https://doi.org/10.3389/fpls.2018.00701
