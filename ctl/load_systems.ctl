LOAD DATA INFILE "systems.tab"
INTO TABLE systems
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(system_id, system)
