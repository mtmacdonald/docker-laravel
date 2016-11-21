#!/bin/bash
# ------------------------------------------------------------------------------
# Provisioning script for the docker-laravel image
# ------------------------------------------------------------------------------

apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# ------------------------------------------------------------------------------
# NGINX web server
# ------------------------------------------------------------------------------

apt-get -y install nginx
cp /provision/service/nginx.conf /etc/supervisord/nginx.conf

#configuration files
cp /provision/conf/nginx/development /etc/nginx/sites-available/default
cp /provision/conf/nginx/production.template /etc/nginx/sites-available/production.template

# disable 'daemonize' in nginx (because we use supervisor instead)
echo "daemon off;" >> /etc/nginx/nginx.conf

# ------------------------------------------------------------------------------
# PHP7
# ------------------------------------------------------------------------------

# install PHP, PHP mcrypt extension and PHP MySQL native driver
apt-get -y install php-fpm php-cli
cp /provision/service/php-fpm.conf /etc/supervisord/php-fpm.conf

apt-get install php-mbstring php-xml
phpenmod mbstring
phpenmod php-xml

# disable 'daemonize' in php-fpm (because we use supervisor instead)
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf

# ------------------------------------------------------------------------------
# MariaDB server
# ------------------------------------------------------------------------------

# install MariaDB client and server
apt-get -y install mariadb-client
apt-get -y install mariadb-server pwgen
cp /provision/service/mariadb.conf /etc/supervisord/mariadb.conf

# copy MariaDB configuration
cp /provision/conf/my.cnf /etc/mysql/my.cnf

# MariaDB seems to have problems starting if these permissions are not set:
mkdir /var/run/mysqld
chmod 777 /var/run/mysqld
