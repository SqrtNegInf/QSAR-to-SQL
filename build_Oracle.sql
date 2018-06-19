DROP TABLE qsar_sets;
create table qsar_sets
        (qsar_id integer PRIMARY KEY,
         system_id integer NOT NULL,
         class_id integer NOT NULL,
         compound_id integer NOT NULL,
         action_id integer NOT NULL,
         citation_id integer NOT NULL,
         model varchar(300) NOT NULL,
         n integer NOT NULL,
         r number(5,3) NOT NULL,
         s number(5,3) NOT NULL)
;

DROP TABLE systems;
create table systems
        (system_id integer PRIMARY KEY,
         system varchar(180))
;

DROP TABLE classes;
create table classes
        (class_id integer PRIMARY KEY,
         class varchar(255))
;

DROP TABLE multi_classes;
create table multi_classes
        (multi_class_id integer PRIMARY KEY,
         class varchar(255),
         qsar_id integer)
;

DROP TABLE compounds;
create table compounds
        (compound_id integer PRIMARY KEY,
         compound varchar(255))
;

DROP TABLE actions;
create table actions
        (action_id integer PRIMARY KEY,
         action varchar2(400))
;

DROP TABLE citations;
create table citations
        (citation_id integer PRIMARY KEY,
         citation varchar2(600))
;

DROP TABLE smiles;
create table smiles
        (smiles_id integer PRIMARY KEY,
         smiles varchar2(300),
         mf varchar(50),
		 mw number(5,2))
;

DROP TABLE structures;
create table structures
        (structure_id integer PRIMARY KEY,
         qsar_id integer NOT NULL,
         smiles_id integer,
         observed number(5,2))
;

DROP TABLE qsar_parameters;
create table qsar_parameters
        (qsar_param_id integer PRIMARY KEY,
         qsar_id integer NOT NULL,
         parameter_label varchar(25) NOT NULL,
         coefficient number(7,2) NOT NULL,
         confidence number(7,2) NOT NULL)
;

