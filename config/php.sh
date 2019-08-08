#!/bin/bash
#set -eu
set -e

PHP_VERSION=7.3

## Current script directory path
CURRENT_DIRECTORY=$(dirname $0)

## -----------------------------------------------------------------------------

## PHP installation
##
## Show list of PHP modules
## dpkg --get-selections | grep -v deinstall | grep php
##
apt-get install -y --no-install-recommends \
  php${PHP_VERSION} \
  php${PHP_VERSION}-gd \
  php${PHP_VERSION}-mbstring \
  php${PHP_VERSION}-opcache \
  php${PHP_VERSION}-xml \
  php${PHP_VERSION}-curl \
  php${PHP_VERSION}-zip \
  php-uploadprogress \
  php-apcu \
  php${PHP_VERSION}-ldap \
  php${PHP_VERSION}-intl \
  php${PHP_VERSION}-mysql \
  php${PHP_VERSION}-sqlite3 \
  php${PHP_VERSION}-pgsql
  # pdo_mysql \
  # mysqli \
  # php${PHP_VERSION}-cli \
  # libpng${PHP_VERSION}-dev \
  # php${PHP_VERSION}-fpm \
  # php${PHP_VERSION}-bz2 \
  # php${PHP_VERSION}-imap \
  # php${PHP_VERSION}-xdebug \





## https://github.com/krakjoe/apcu/blob/master/apc.php (APCu info page)



## Time zone
sed -i 's/;date.timezone =/date.timezone = "Europe\/Prague"/' /etc/php/${PHP_VERSION}/cli/php.ini

## PHP configuration
cat << EOF > /etc/php/${PHP_VERSION}/apache2/conf.d/php-default.ini
[Time zone]
date.timezone="Europe/Prague"

[Error reporting]
log_errors=On
error_log=php_error.log
error_reporting=E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors=Off
;display_startup_errors=Off
;track_errors=Off
;mysqlnd.collect_memory_statistics=Off
;zend.assertions=-1
;opcache.huge_code_pages=1

[Upload files]
post_max_size=256M
upload_max_filesize=128M

[Performance]
memory_limit=256M
max_execution_time=120
max_input_time=60

[OPcode extension]
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1

[Drupal Commerce Kickstart]
;mbstring.http_input=pass
;mbstring.http_output=pass

[MongoDB]
;extension=mongo.so
;extension=mongodb.so

[E-mail]
sendmail_path=/usr/sbin/sendmail -t -i
;sendmail_path=/usr/sbin/ssmtp -t
EOF

## PHP configuration
cp $CURRENT_DIRECTORY/php-dev.ini /etc/php/${PHP_VERSION}/apache2/conf.d/



## Composer (old)
#apt-get install -y composer

## Composer (latest)
## Directory /usr/local/bin can use proxy
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

## -----------------------------------------------------------------------------

## Services
#service apache2 reload
#service swapspace status





## PHP Major.Minor version
#PHP_TEST=$(php -v | cut -d" " -f2 | cut -d"." -f1,2 | head -1)

## PHP Major.Minor.Patch version
#PHP_TEST=$(php -v | head -1 | cut -d" " -f2 | cut -d"-" -f1)

## Show PHP version
#echo "Current PHP version: $PHP_TEST"
