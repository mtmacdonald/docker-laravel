#!/bin/bash
# ------------------------------------------------------------------------------
# Provisioning script for the docker-laravel web server stack
# ------------------------------------------------------------------------------

apt-get update

# ------------------------------------------------------------------------------
# curl
# ------------------------------------------------------------------------------

apt-get -y install curl libcurl3 libcurl3-dev php5-curl

# ------------------------------------------------------------------------------
# Supervisor
# ------------------------------------------------------------------------------

apt-get -y install python # Install python (required for Supervisor)

mkdir -p /etc/supervisord/
mkdir /var/log/supervisord

# copy all conf files
cp /provision/conf/supervisor.conf /etc/supervisord.conf
cp /provision/service/* /etc/supervisord/

curl https://bootstrap.pypa.io/ez_setup.py -o - | python

easy_install supervisor

# ------------------------------------------------------------------------------
# SSH
# ------------------------------------------------------------------------------

apt-get -y install openssh-server
mkdir /var/run/sshd
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

#keys
mkdir -p /root/.ssh
chmod 700 /root/.ssh
chown root:root /root/.ssh
cp /provision/keys/insecure_key.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# ------------------------------------------------------------------------------
# cron
# ------------------------------------------------------------------------------

apt-get -y install cron

# ------------------------------------------------------------------------------
# nano
# ------------------------------------------------------------------------------

apt-get -y install nano

# ------------------------------------------------------------------------------
# NGINX web server
# ------------------------------------------------------------------------------
add-apt-repository ppa:nginx/stable

apt-get update

# install nginx
apt-get -y install nginx

# copy a development-only default site configuration
cp /provision/conf/nginx-development /etc/nginx/sites-available/default

# disable 'daemonize' in nginx (because we use supervisor instead)
echo "daemon off;" >> /etc/nginx/nginx.conf

# ------------------------------------------------------------------------------
# PHP5
# ------------------------------------------------------------------------------

# install PHP, PHP mcrypt extension and PHP MySQL native driver
apt-get -y install php5-fpm php5-cli php5-mcrypt php5-mysqlnd

# copy FPM and CLI PHP configurations
cp /provision/conf/php.fpm.ini /etc/php5/fpm/php.ini
cp /provision/conf/php.cli.ini /etc/php5/cli/php.ini

# enable PHP mcrypt extension
php5enmod mcrypt

# disable 'daemonize' in php5-fpm (because we use supervisor instead)
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf

# ------------------------------------------------------------------------------
# MySQL server
# ------------------------------------------------------------------------------

# install MySQL client and server
apt-get -y install mysql-client
apt-get -y install mysql-server pwgen

# copy MySQL configuration
cp /provision/conf/my.cnf /etc/mysql/my.cnf

# ------------------------------------------------------------------------------
# Node and npm
# ------------------------------------------------------------------------------

curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
sudo apt-get install -y nodejs

# ------------------------------------------------------------------------------
# Git version control
# ------------------------------------------------------------------------------

# install git
apt-get -y install git

# ------------------------------------------------------------------------------
# Composer PHP dependency manager
# ------------------------------------------------------------------------------

# install the latest version of composer
php -r "readfile('https://getcomposer.org/installer');" | php
mv composer.phar /usr/local/bin/composer

# ------------------------------------------------------------------------------
# Beanstalkd task queue
# ------------------------------------------------------------------------------

apt-get -y install beanstalkd

# ------------------------------------------------------------------------------
# wkhtmltopdf (PDF generator)
#
# Ubuntu ships with an old version so instead copy tool from this repository
#
# Libxrender is used for headless PDF generation on servers without a GUI
# ------------------------------------------------------------------------------

apt-get -y install libxrender1
cp /provision/bin/wkhtmltopdf /usr/bin/wkhtmltopdf

# ------------------------------------------------------------------------------
# PhantomJS (headless browser)
#
# (Ubuntu package is tool old)
# ------------------------------------------------------------------------------

curl -L -o /tmp/phantomjs.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2
mkdir /tmp/phantomjs
tar xvfj /tmp/phantomjs.tar.bz2 -C /tmp/phantomjs --strip 1
cp /tmp/phantomjs/bin/phantomjs /usr/bin/phantomjs
chmod +x /usr/bin/phantomjs

# ------------------------------------------------------------------------------
# XDEBUG (installed but disabled by default)
# ------------------------------------------------------------------------------

apt-get -y install php5-xdebug
cp /provision/conf/xdebug.ini /etc/php5/mods-available/xdebug.ini

# ------------------------------------------------------------------------------
# Copy an install script for Selenium server PhantomJS (test tool)
# This is no longer installed by default because it requires the JRE and is large
# ------------------------------------------------------------------------------

cp /provision/bin/selenium-setup.sh /home/selenium-setup.sh

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------
rm -rf /provision
