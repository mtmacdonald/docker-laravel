#!/bin/bash
# ------------------------------------------------------------------------------
# Provisioning script for the Larazest web server stack
# ------------------------------------------------------------------------------

apt-get update

# ------------------------------------------------------------------------------
# Install curl
# ------------------------------------------------------------------------------

apt-get -y install curl libcurl3 libcurl3-dev php5-curl

# ------------------------------------------------------------------------------
# Install python (required for Supervisor)
# ------------------------------------------------------------------------------

apt-get -y install python

# ------------------------------------------------------------------------------
# Install Supervisor
# ------------------------------------------------------------------------------

mkdir -p /etc/supervisor/conf.d
mkdir /var/log/supervisord

# copy all conf files
cp /provision/conf/supervisor/supervisor.conf /etc/supervisor.conf
cp /provision/conf/supervisor/conf.d/* /etc/supervisor/conf.d

curl https://bootstrap.pypa.io/ez_setup.py -o - | python

easy_install supervisor

# ------------------------------------------------------------------------------
# Install SSH
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
# Install cron
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Install nano
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# NGINX web server
# ------------------------------------------------------------------------------

# install nginx
apt-get -y install nginx

# copy a development-only default site configuration
cp /provision/conf/nginx-development /etc/nginx/sites-available/default

# disable 'daemonize' in nginx (because we use runit instead)
echo "daemon off;" >> /etc/nginx/nginx.conf

# use runit to supervise nginx
mkdir /etc/service/nginx
cp /provision/service/nginx.sh /etc/service/nginx/run

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

# use Supervisor supervise php5-fpm
# cp /provision/service/phpfpm.sh /etc/service/phpfpm/run

# ------------------------------------------------------------------------------
# MySQL server
# ------------------------------------------------------------------------------

# install MySQL client and server
apt-get -y install mysql-client
apt-get -y install mysql-server pwgen

# copy MySQL configuration
cp /provision/conf/my.cnf /etc/mysql/my.cnf

# use runit to supervise mysql
# mkdir /etc/service/mysql
# cp /provision/service/mysql.sh /etc/service/mysql/run

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

# use runit to supervise beanstalkd
# mkdir /etc/service/beanstalkd
# cp /provision/service/beanstalkd.sh /etc/service/beanstalkd/run

# use runit to supervise the 'php artisan queue:listen' command
# mkdir /etc/service/queue
# cp /provision/service/queue.sh /etc/service/queue/run

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------
rm -rf /provision