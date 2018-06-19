#!/bin/sh
## build mySQL database from .list/.pack source, and display all tables
#  David H.  Tue Jan 21 08:17:55 PST 2003
# first create an account that can create/delete the databases
#cd /Library/MySQL; binin bin

mysql GRANT ALL PRIVILEGES ON *.* TO 'qsar-user'@'localhost';

# start fresh each time...
mysqladmin -f -u qsar-user drop   qsar-bio
mysqladmin -f -u qsar-user drop   qsar-phys
mysqladmin    -u qsar-user create qsar-bio
mysqladmin    -u qsar-user create qsar-phys

# build BIO from scratch
molform < bio.usmi  | perl -npe 's/m[fw]=//g;s/~\S+//' > bio.mfmw
QSAR_SQL bio.list bio.pack bio.mfmw bio_class.dat
mysql -u qsar-user -vvv < bio-build_mySQL.sql > bio-build.log        2>&1
mysql -u qsar-user -v   < bio-view_mySQL.sql  > bio-tables.txt
rm -rf bio; mkdir bio; mv *tab bio

# build PHYS from scratch 
molform < phys.usmi | perl -npe 's/m[fw]=//g;s/~\S+//' > phys.mfmw
QSAR_SQL phys.list phys.pack phys.mfmw phys_class.dat
mysql -u qsar-user -vvv < phys-build_mySQL.sql > phys-build.log        2>&1
mysql -u qsar-user -v   < phys-view_mySQL.sql  > phys-tables.txt
rm -rf phys; mkdir phys; mv *tab phys
