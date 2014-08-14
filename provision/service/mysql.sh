#!/bin/bash

# fetch the debian-sys-maint password
PASS=$(awk '/^password/ {print $3; exit}' /etc/mysql/debian.cnf)

# workaround for MySQL which doesn't terminate when receiving a TERM signal
# see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=208364
trap 'mysqladmin -u debian-sys-maint -p$PASS shutdown' EXIT

mysqld_safe
