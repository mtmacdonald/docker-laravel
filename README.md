Ubuntu Docker container for Laravel web applications
====================================================

Docker-laravel is a LEMP base image for running [Laravel](https://github.com/laravel/laravel) web applications. It
is loosely inspired by [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker).

Required and optional packages are bundled into a single container, based on Ubuntu 14.04 server.

These services run with process supervision, using [Supervisor](http://supervisord.org):

- nginx
- php5-fpm (with php5-mcrypt, php5-mysqlnd, and php5-curl)
- mysql-server
- openssh-server
- cron
- beanstalkd

Additionally, these services can optionally be enabled for process supervision (see below):

- artisan queue:listen
- selenium server (for testing, not production)

These packages are preinstalled:

- nodejs with npm
- nano
- git
- php5-cli
- mysql-client
- composer
- curl
- phantomjs
- wkhtmltopdf
- php5-xdebug (installed, but disabled by default, see below)
- python (*dependency for supervisord)
- default-jre (*dependency for Selenium server)

Running a container
-------------------

**1.** Download the public Docker image from Dockerhub:

	docker pull mtmacdonald/docker-laravel:1.4.0

**2.** Run the Docker image as a new Docker container:

	docker run -d \
	-p 80:80 -p 443:443 -p 3306:3306 \
	-v /home/app:/share \
	--restart=always \
	--name=appname \
	mtmacdonald/docker-laravel:1.4.0

Replace '/home/app' with the path to the Laravel application's root directory in the host. This directory is a shared 
volume and so can be used to access the application files in either the host or the container.

Connecting to a container with SSH
----------------------------------

**Development use (insecure)**

Docker-laravel ships with SSH server for accessing a terminal inside the container. For convenience, it is preconfigured 
with an insecure key that should be replaced for production use. To connect with the insecure key:

**1.** Fetch the insecure SSH key:

	cd /home/
	curl -o insecure_key -fSL https://raw.githubusercontent.com/mtmacdonald/docker-laravel/master/provision/keys/insecure_key
	chown `whoami` insecure_key
	chmod 600 insecure_key

**2.** Find the I.P. address of the container:

	docker inspect container_name | grep IPA

**3.** Connect with SSH:

	ssh -i /home/insecure_key root@<IP address>

**Production use**

For production, replace the insecure private key with a true private key:

**1.** In the host, generate a new public-private key pair (enter 'production.key') when prompted:

	cd /home
	sudo ssh-keygen -t rsa
	sudo chmod 644 production.key

There should then be two new files in the */home* directory: i) production.key ii) production.key.pub

**2.** Copy *production.key.pub* to */root/.ssh/authorized_keys* in the container. Note this is an overwrite, not an append 
(so all previously valid keys, including *insecure_key* will be removed).

	cat /home/production.key.pub | ssh -i /home/insecure_key root@<IP address> "cat > /root/.ssh/authorized_keys"

**3.** Connect with SSH:

	ssh -i /home/production.key root@<IP address>

Process status
--------------

**supervisorctl** can be used to control the processes that are managed by supervisor.

*In the container*:

	supervisorctl

Installing Laravel
------------------

Laravel is not bundled in the Docker image. Laravel, or your own application, need to be installed manually:

*In the container*:

	cd /share
	git clone https://github.com/laravel/laravel .
	composer install

Queue:listen
------------

The queue listener (**php artisan queue:listen**) can be added as supervised process by uncommenting the lines in
**/etc/supervisord/queue.conf** (in the container).

Selenium server
---------------

Selenium server (for automated headless browser testing with PhantomJS) is installed but does not run by default. 
Uncomment the lines in **/etc/supervisord/selenium.conf** to add selenium as a supervised process.

XDEBUG
------

The XDEBUG PHP extension is installed but not enabled by default. To enable it, uncomment the lines in 
**/etc/php5/mods-available/xdebug.ini**.