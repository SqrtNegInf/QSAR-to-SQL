LOAD DATA INFILE "actions.tab"
INTO TABLE actions
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(action_id, action char(400))
