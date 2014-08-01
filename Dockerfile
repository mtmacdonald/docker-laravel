# Docker provisioning script for Larazest web stack
FROM ubuntu:14.04
MAINTAINER Mark Macdonald <mark.t.macdonald@googlemail.com>
RUN apt-get -qq update
RUN apt-get -qqy install php5

