#!/bin/bash

# initialize the data directory, only if not already populated
# 	alternative would be mysql_install_db (but then see debian-sys-maint user)
if [ ! -f /share/data/ibdata1 ]; then
	rsync -r /var/lib/mysql /share/data
fi

# make sure the MySQL user owns the data directory
chown -R mysql /share/data/

# start services
service nginx start
service php5-fpm start
service mysql start
service ssh start
bin/bash