LOAD DATA INFILE "qsar_sets.tab"
INTO TABLE qsar_sets
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(qsar_id, system_id, class_id, compound_id, action_id, citation_id, model char(400), n, r, s)
