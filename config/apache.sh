#!/bin/bash
set -eu

#!/bin/bash -x

## Configuration
WORKSPACE=/var/www/html
DOCROOT=${WORKSPACE}/public
#APACHE_RUN_USER www-data
#APACHE_RUN_GROUP www-data
#APACHE_LOG_DIR /var/log/apache2

#if test -z $1 ; then
#  echo "The arg is empty"
#  # Do something
#else
#  echo "The arg is $1"
#  # Do something
#fi

## Current script directory path
CURRENT_DIRECTORY=$(dirname $0)

## Environment variables
#source "$CURRENT_DIRECTORY/env.sh"

## -----------------------------------------------------------------------------

## Apache
apt-get install -y --no-install-recommends \
  apache2

## Workspace
rm -rf /var/www/*
mkdir -p ${DOCROOT}
#mkdir -p ${WORKSPACE}/private
#echo "<?php phpinfo();" > ${DOCROOT}/info.php
#echo "Public folder" > ${DOCROOT}/index.html

## Extract archive (Create archive: tar -cvzf public.tar.gz public)
tar -xvzf /tmp/public.tar.gz -C ${WORKSPACE}



#cat << EOF > /var/www/html/public/index.html
#<!doctype html>
#<html>
#<head>
#  <meta charset="utf-8">
#  <title>It works!</title>
#</head>
#<body>
#  <h1>It works!</h1>
#</body>
#</html>
#EOF

## Apache website permissions
#apt-get install -y --no-install-recommends \
#  libapache2-mpm-itk
#a2enmod mpm_itk

## Apache clean URL and caching
a2enmod rewrite expires

## Apache header
a2enmod headers

## Extension order (PHP first)
sed -i 's/DirectoryIndex index.html index.cgi index.pl index.php/DirectoryIndex index.php index.cgi index.pl index.html/' /etc/apache2/mods-enabled/dir.conf

## Apache configuration
## Variable in file does not work!
#cp $CURRENT_DIRECTORY/apache-dev.conf /etc/apache2/sites-available/000-default.conf

## -----------------------------------------------------------------------------

## Services
#service apache2 restart
