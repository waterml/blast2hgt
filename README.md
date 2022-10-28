Blast2hgt
------
Determine horizontal transfer candidates based on sequence similarity,   
and reconstruct a phylogenetic tree to confirm the horizontal transfer event.

The query objects can be proteins, genes or partitial genomic sequences.   

**Note:**A MySQL database of BLAST hit's sequences and their species taxonomy is required.   
i.e.,   
If the BLAST database is nr, you have to import the nr sequence IDs and their taxonomy IDs into the MySQL database (use `import_nr.acc.taxid.sql`).   
If the nt is blasted, the nt sequence IDs and their taxonomy IDs should be imported.   

**See `Blast2hgt_manual.pdf` for user guide.**  

If you find this useful, please cite:   
Li, M., Zhao, J., Tang, N., Sun, H., & Huang, J. (2018). Horizontal Gene Transfer From Bacteria and Plants to the Arbuscular Mycorrhizal Fungus Rhizophagus irregularis. Frontiers in Plant Science, 9, 701. https://doi.org/10.3389/fpls.2018.00701
