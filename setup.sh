#!/bin/bash

DB_USER='root'
DB_PASS=''

# Configure MySQL timezones
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u "$DB_USER" --password="$DB_PASS" --database="mysql"

