LOAD DATA INFILE "citations.tab"
INTO TABLE citations
FIELDS  TERMINATED  BY  ','  OPTIONALLY  ENCLOSED  BY  '"'
(citation_id, citation char(600))
