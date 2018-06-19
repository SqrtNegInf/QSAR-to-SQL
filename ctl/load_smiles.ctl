LOAD DATA INFILE "smiles.tab"
INTO TABLE smiles
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(smiles_id, smiles)
