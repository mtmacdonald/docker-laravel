# ------------------------------------------------------------------------------
# Optional script for installing Selenium server
# 	(no longer ships as part of the base image - run this script manually if
#	 Selenium is required inside a test container)
# 
# Remember to also enable Selenium by uncommenting /etc/supervisord/selenium.conf
# ------------------------------------------------------------------------------

# Selenium server (not available as a Ubuntu package, depends on JRE)
apt-get update
apt-get -y install default-jre
mkdir /usr/local/selenium
curl -o /usr/local/selenium/selenium.jar http://selenium-release.storage.googleapis.com/2.42/selenium-server-standalone-2.42.2.jar
mkdir -p /var/log/selenium/
chmod a+w /var/log/selenium/
