LOAD DATA INFILE "qsar_parameters.tab"
INTO TABLE qsar_parameters
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(qsar_param_id, qsar_id, parameter_label, coefficient, confidence)
