Ubuntu Docker container for Laravel web applications
====================================================

Docker-laravel is a LEMP image for running
[Laravel](https://github.com/laravel/laravel) web applications.

It extends [docker-base](https://github.com/mtmacdonald/docker-base), which
contains [Supervisor](http://supervisord.org) for process supervision, and other
basic utilities. It is loosely inspired by
[phusion/baseimage-docker](https://github.com/phusion/baseimage-docker).

All packages for running a Laravel web app are bundled into a single image,
based on Ubuntu 16.04 server.

These services run with process supervision:

- cron
- nginx
- php-fpm (with extensions required for Laravel 5, plus php5-mysqlnd and and php5-curl)
- mariadb-server
- beanstalkd
- artisan queue:listen

These packages are preinstalled:

- nano
- curl
- git
- zip and unzip
- php-cli
- php-xdebug (installed, but disabled by default, see below)
- composer
- mariadb-client
- nodejs with npm
- phantomjs
- wkhtmltopdf

Running a container
-------------------

**1.** Download the public Docker image from Dockerhub:

		docker pull mtmacdonald/docker-laravel:version

**2.** Run the Docker image as a new Docker container:

		docker run -d \
		-p 80:80 -p 443:443 -p 3306:3306 \
		-v /home/app:/share \
		--restart=always \
		--name=appname \
		mtmacdonald/docker-laravel:version

Replace '/home/app' with the path to the Laravel application's root directory in
the host. This directory is a shared volume and so can be used to access the
application files in either the host or the container.

Managing the container
----------------------

See the instructions in [docker-base](https://github.com/mtmacdonald/docker-base).

Installing Laravel
------------------

Laravel is not bundled in the Docker image. Laravel, or your own application,
need to be installed manually:

*In the container (see docker exec)*:

		cd /share
		git clone https://github.com/laravel/laravel .
		composer install
		chmod -R guo+w storage
		cp .env.example .env
		php artisan key:generate

XDebug
------

The XDebug PHP extension is installed but not enabled by default. To enable it:

		phpenmod xdebug
		phpenmod -s cli xdebug
