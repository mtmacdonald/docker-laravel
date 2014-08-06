# Docker provisioning script for Larazest web server stack

FROM ubuntu:14.04
MAINTAINER Mark Macdonald <mark.t.macdonald@googlemail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update

# Allow 'universe' packages (needed for php5-mysqlnd)
# RUN apt-get -qqy install software-properties-common
# RUN add-apt-repository universe
# RUN apt-get -qq update

# Install nano text editor
RUN apt-get -qqy install nano

# Install nginx
RUN apt-get -qqy install nginx
ADD default /etc/nginx/sites-available/default

# Install PHP
RUN apt-get -qqy install php5-fpm php5-cli php5-mcrypt php5-mysqlnd
ADD php.fpm.ini /etc/php5/fpm/php.ini
ADD php.cli.ini /etc/php5/cli/php.ini

# Enable mcrypt
RUN php5enmod mcrypt

# Install MySQL
RUN apt-get -qqy install mysql-client
RUN apt-get -qqy install mysql-server pwgen

ADD my.cnf /etc/mysql/my.cnf
ADD setup.sh /tmp/setup.sh
RUN chmod 755 /tmp/setup.sh

# Start the MySQL service and run setup script
RUN service mysql restart && /tmp/setup.sh

# Expose ports
EXPOSE 80

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
