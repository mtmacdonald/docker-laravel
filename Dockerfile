# Docker provisioning script for Larazest web server stack

FROM ubuntu:14.04
MAINTAINER Mark Macdonald <mark.t.macdonald@googlemail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update

# Install nano text editor
RUN apt-get -qqy install nano

# Install git version control
RUN apt-get -qqy install git

# Install nginx web server
RUN apt-get -qqy install nginx
ADD default /etc/nginx/sites-available/default

# Install PHP
RUN apt-get -qqy install php5-fpm php5-cli php5-mcrypt php5-mysqlnd
ADD php.fpm.ini /etc/php5/fpm/php.ini
ADD php.cli.ini /etc/php5/cli/php.ini

# Enable mcrypt
RUN php5enmod mcrypt

# Install Ruby and some gems
# Not that Nokogiri gem requires build tools, Ruby developer packages and libxml2/libxslt.
RUN apt-get -qqy install build-essential
RUN apt-get -qqy install ruby ruby-dev
RUN apt-get -qqy install libxslt-dev libxml2-dev
RUN gem install systemu --no-ri --no-rdoc
RUN gem install kramdown --no-ri --no-rdoc
RUN gem install kwalify --no-ri --no-rdoc
RUN gem install nokogiri --no-ri --no-rdoc

# Install wkhtmltopdf (requires libxrender1)
RUN apt-get -qqy install libxrender1
ADD wkhtmltopdf /usr/bin/wkhtmltopdf
RUN chmod 755 /usr/bin/wkhtmltopdf

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
