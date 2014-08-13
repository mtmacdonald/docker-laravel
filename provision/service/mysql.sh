#!/bin/bash

if [ ! -f /share/data/ibdata1 ]; then
	rsync -r /var/lib/mysql /share/data
fi

# Mysql startup taken from runit docs: http://smarden.org/runit1/runscripts.html
MYSQLADMIN='/usr/bin/mysqladmin --defaults-extra-file=/etc/mysql/debian.cnf'

trap "$MYSQLADMIN shutdown" 0
trap 'exit 2' 1 2 3 15

/usr/bin/mysqld_safe & wait
