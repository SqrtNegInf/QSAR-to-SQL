LOAD DATA INFILE "multi_classes.tab"
INTO TABLE multi_classes
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(multi_class_id, class, qsar_id)
