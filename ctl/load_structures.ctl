LOAD DATA INFILE "structures.tab"
INTO TABLE structures
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(structure_id, qsar_id, smiles_id, observed)
