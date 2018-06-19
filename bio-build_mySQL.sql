use qsar-bio;

DROP TABLE IF EXISTS qsar_sets;
create table qsar_sets
        (qsar_id integer PRIMARY KEY,
         system_id integer NOT NULL,
         class_id integer NOT NULL,
         compound_id integer NOT NULL,
         action_id integer NOT NULL,
         citation_id integer NOT NULL,
         note_id integer NOT NULL,
         model text NOT NULL,
         n integer NOT NULL,
         r float(5,3) NOT NULL,
         s float(5,3) NOT NULL)
;
LOAD DATA INFILE "/bb/export/SQL/qsar/qsar_sets.tab"
INTO TABLE qsar_sets
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(qsar_id, system_id, class_id, compound_id, action_id, citation_id, note_id, model, n, r, s)
;

DROP TABLE IF EXISTS systems;
create table systems
        (system_id integer PRIMARY KEY,
         system varchar(180))
;
LOAD DATA INFILE "/bb/export/SQL/qsar/systems.tab"
INTO TABLE systems
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(system_id, system)
;

DROP TABLE IF EXISTS classes;
create table classes
        (class_id integer PRIMARY KEY,
         class varchar(255))
;
LOAD DATA INFILE "/bb/export/SQL/qsar/classes.tab"
INTO TABLE classes
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(class_id, class)
;

DROP TABLE IF EXISTS multi_classes;
create table multi_classes
        (multi_class_id integer PRIMARY KEY,
         multi_class varchar(255),
         qsar_id integer)
;
LOAD DATA INFILE "/bb/export/SQL/qsar/multi_classes.tab"
INTO TABLE multi_classes
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(multi_class_id, multi_class, qsar_id)
;

DROP TABLE IF EXISTS compounds;
create table compounds
        (compound_id integer PRIMARY KEY,
         compound varchar(255))
;
LOAD DATA INFILE "/bb/export/SQL/qsar/compounds.tab"
INTO TABLE compounds
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(compound_id, compound)
;

DROP TABLE IF EXISTS actions;
create table actions
        (action_id integer PRIMARY KEY,
         action text)
;
LOAD DATA INFILE "/bb/export/SQL/qsar/actions.tab"
INTO TABLE actions
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(action_id, action)
;

DROP TABLE IF EXISTS citations;
create table citations
        (citation_id integer PRIMARY KEY,
         citation text)
;
LOAD DATA INFILE "/bb/export/SQL/qsar/citations.tab"
INTO TABLE citations
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(citation_id, citation)
;

DROP TABLE IF EXISTS notes;
create table notes
        (note_id integer PRIMARY KEY,
         note text)
;
LOAD DATA INFILE "/bb/export/SQL/qsar/notes.tab"
INTO TABLE notes
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(note_id, note)
;

DROP TABLE IF EXISTS smiles;
create table smiles
        (smiles_id integer PRIMARY KEY,
         smiles text,
         mf varchar(50),
		 mw float(5,2))
;
LOAD DATA INFILE "/bb/export/SQL/qsar/smiles.tab"
INTO TABLE smiles
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(smiles_id, smiles, mf, mw)
;

DROP TABLE IF EXISTS structures;
create table structures
        (structure_id integer PRIMARY KEY,
         qsar_id integer NOT NULL,
         smiles_id integer,
         omitted integer,
         observed float(5,2))
;
LOAD DATA INFILE "/bb/export/SQL/qsar/structures.tab"
INTO TABLE structures
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(structure_id, qsar_id, smiles_id, omitted, observed)
;

DROP TABLE IF EXISTS qsar_parameters;
create table qsar_parameters
        (qsar_param_id integer PRIMARY KEY,
         qsar_id integer NOT NULL,
         parameter_label varchar(25) NOT NULL,
         coefficient float(7,2) NOT NULL,
         confidence float(7,2) NOT NULL)
;
LOAD DATA INFILE "/bb/export/SQL/qsar/qsar_parameters.tab"
INTO TABLE qsar_parameters
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(qsar_param_id, qsar_id, parameter_label, coefficient, confidence)
;

#DROP TABLE IF EXISTS xxx;
#create table xxx
#        (xxx integer PRIMARY KEY,
#         xxx varchar(25) NOT NULL,
#         xxx float(5,2) NOT NULL)
#;
#LOAD DATA INFILE "/bb/export/SQL/qsar/xxx.tab"
#INTO TABLE xxx
#FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
#(xxx, xxx, xxx)
#;
