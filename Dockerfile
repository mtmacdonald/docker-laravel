# Docker provisioning script for Larazest web server stack

FROM ubuntu:14.04
MAINTAINER Mark Macdonald <mark.t.macdonald@googlemail.com>
RUN apt-get -qq update

# Install nginx
RUN sudo apt-get -qqy install nginx

# Install PHP
RUN apt-get -qqy install php5-fpm

