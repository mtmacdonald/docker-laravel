# Docker provisioning script for Larazest web server stack

FROM ubuntu:14.04
MAINTAINER Mark Macdonald <mark.t.macdonald@googlemail.com>
RUN apt-get -qq update

#install nano text editor
RUN apt-get install -qqy nano

# Install nginx
RUN sudo apt-get -qqy install nginx

# Install PHP
RUN apt-get -qqy install php5-fpm php5-cli php5-mcrypt

# Enable mcrypt
RUN php5enmod mcrypt

ADD default /etc/nginx/sites-available/default

# Expose ports
EXPOSE 80

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
