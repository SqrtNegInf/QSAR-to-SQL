LOAD DATA INFILE "compounds.tab"
INTO TABLE compounds
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(compound_id, compound)
