# ------------------------------------------------------------------------------
# Docker provisioning script for the Larazest web server stack
# ------------------------------------------------------------------------------

FROM ubuntu:14.04

MAINTAINER Mark Macdonald <mark.t.macdonald@googlemail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update

# ------------------------------------------------------------------------------
# Install some useful tools
# ------------------------------------------------------------------------------

# Nano text editor
RUN apt-get -qqy install nano

# Git version control
RUN apt-get -qqy install git

# SSH server
RUN apt-get -qqy install openssh-server

# ------------------------------------------------------------------------------
# Install NGINX, PHP5, MySQL server stack for Laravel
# 
# Must use PHP MySQL native drivers (php5-mysqlnd and not php5-mysql)
#
# Laravel requires the mcyrpt PHP extension
# ------------------------------------------------------------------------------

# NGINX web server
RUN apt-get -qqy install nginx
ADD default /etc/nginx/sites-available/default

# PHP
RUN apt-get -qqy install php5-fpm php5-cli php5-mcrypt php5-mysqlnd
ADD php.fpm.ini /etc/php5/fpm/php.ini
ADD php.cli.ini /etc/php5/cli/php.ini

# Enable mcrypt
RUN php5enmod mcrypt

# MySQL
RUN apt-get -qqy install mysql-client
RUN apt-get -qqy install mysql-server pwgen
ADD my.cnf /etc/mysql/my.cnf
ADD setup.sh /tmp/setup.sh
RUN chmod 755 /tmp/setup.sh

# Start the MySQL service and run setup script
RUN service mysql restart && /tmp/setup.sh

# ------------------------------------------------------------------------------
# Install Composer PHP dependency manager
# ------------------------------------------------------------------------------

# Composer 
RUN php -r "readfile('https://getcomposer.org/installer');" | php
RUN mv composer.phar /usr/local/bin/composer

# ------------------------------------------------------------------------------
# Install Ruby and some gems
#
# The Nokogiri gem has to be compiled and linked against libxml2 and libxslt.
# ------------------------------------------------------------------------------

# Ruby
RUN apt-get -qqy install ruby ruby-dev

# Gems
RUN gem install systemu --no-ri --no-rdoc
RUN gem install kramdown --no-ri --no-rdoc
RUN gem install kwalify --no-ri --no-rdoc

# Nokogiri Gem (requires compilation)
RUN apt-get -qqy install build-essential
RUN apt-get -qqy install libxslt-dev libxml2-dev
RUN gem install nokogiri --no-ri --no-rdoc

# ------------------------------------------------------------------------------
# Install wkhtmltopdf (PDF generator)
#
# Ubuntu ships with an old version so instead copy tool from this repository
#
# Libxrender is used for headless PDF generation on servers without a GUI
# ------------------------------------------------------------------------------

# wkhtmltopdf
RUN apt-get -qqy install libxrender1
ADD wkhtmltopdf /usr/bin/wkhtmltopdf
RUN chmod 755 /usr/bin/wkhtmltopdf

# ------------------------------------------------------------------------------
# Install test tools
# ------------------------------------------------------------------------------

# CURL (required for Codeception test tool)
RUN apt-get -qqy install curl libcurl3 libcurl3-dev php5-curl

# Selenium server (not available as a Ubuntu package)
RUN apt-get -qqy install default-jre
RUN mkdir /usr/local/selenium
RUN curl -o /usr/local/selenium/selenium.jar http://selenium-release.storage.googleapis.com/2.42/selenium-server-standalone-2.42.2.jar
RUN mkdir -p /var/log/selenium/
RUN chmod a+w /var/log/selenium/
ADD selenium /etc/init.d/selenium
RUN chmod 755 /etc/init.d/selenium

# PhantomJS headless browser (Ubuntu package is tool old)
RUN curl -L -o /tmp/phantomjs.tar.bz https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2
RUN mkdir /tmp/phantomjs
RUN tar -xjvf /tmp/phantomjs.tar.bz -C /tmp/phantomjs --strip 1
RUN cp /tmp/phantomjs/bin/phantomjs /usr/bin/phantomjs
RUN chmod 755 /usr/bin/phantomjs

# ------------------------------------------------------------------------------
# Prepare image for use
# ------------------------------------------------------------------------------

# Expose ports
EXPOSE 80

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
