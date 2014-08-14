#!/bin/bash

# if /share/data doesn't exist, copy the default MySQL data directory
if [ ! -f /share/data/ibdata1 ]; then
	mkdir -p /share/data
	cp -r /var/lib/mysql/* /share/data
	chown -R mysql /share/data
fi

# fetch the debian-sys-maint password
PASS=$(awk '/^password/ {print $3; exit}' /etc/mysql/debian.cnf)

# workaround for MySQL which doesn't terminate when receiving a TERM signal
# see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=208364
trap 'mysqladmin -u debian-sys-maint -p$PASS shutdown' EXIT

mysqld_safe
