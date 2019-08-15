## Fix: Remove error building note "debconf: delaying package configuration, since apt-utils is not installed"

## Variables (php:7.3-apache | php:7.2-apache-stretch)
ARG PHP_VERSION=apache
ARG WORKGROUP=VEVVA

## Base image
FROM php:${PHP_VERSION}

## Environment
ENV WORKSPACE=/var/www/html
ENV DOCROOT=${WORKSPACE}/public
#ENV APACHE_RUN_USER www-data
#ENV APACHE_RUN_GROUP www-data
#ENV APACHE_LOG_DIR /var/log/apache2
ENV SSH_USER=www-data
ENV SSH_PASSWD=www-data
ENV WORKGROUP=${WORKGROUP}
ENV SAMBA_USER=www-data
ENV SAMBA_PASSWD=www-data
#ENV WORDPRESS_VERSION=latest
#ENV DRUPAL_VERSION=8.7.5

## Configuration (before instalation)
#RUN echo "Configuration (before instalation)"

## Sources
RUN apt-get update

## Disable dilaying package configuration notification
ARG DEBIAN_FRONTEND=noninteractive
#RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get install --assume-yes apt-utils

## Debian
COPY config/debian.sh /tmp/
RUN chmod u+x /tmp/debian.sh \
    && /tmp/debian.sh

## Apache
COPY config/apache.sh /tmp/
COPY config/apache-dev.conf /tmp/
COPY config/public.tar.gz /tmp/
RUN chmod u+x /tmp/apache.sh \
    && /tmp/apache.sh

## PHP
COPY config/php.sh /tmp/
COPY config/php-dev.ini /tmp/
RUN chmod u+x /tmp/php.sh \
    && /tmp/php.sh

## Samba
COPY config/samba.sh /tmp/
COPY config/smb.conf /tmp/
RUN chmod u+x /tmp/samba.sh \
    && /tmp/samba.sh ${WORKGROUP}

## Nodejs
COPY config/nodejs.sh /tmp/
RUN chmod u+x /tmp/nodejs.sh \
    && /tmp/nodejs.sh

## Drupal tools
COPY config/drupal-tools.sh /tmp/
RUN chmod u+x /tmp/drupal-tools.sh \
    && /tmp/drupal-tools.sh

## Public folder (webserver-info)
#COPY ./public/ /var/www/html/public/

## Apache configuration (Variable from script file does not work!)
COPY config/apache-dev.conf /etc/apache2/sites-available/000-default.conf

## Samba configuration (Variable from script file does not work!)
COPY config/smb.conf /etc/samba/smb.conf
## Add Samba user
RUN (echo ${SAMBA_PASSWD}; echo ${SAMBA_PASSWD}) | smbpasswd -s -a ${SAMBA_USER} 1>/dev/null







## PHP extensions
RUN apt-get install -y --no-install-recommends \
        ## php-zip
        libzip-dev \
        zip \
        ## php-gd
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        ## php-intl
        zlib1g-dev \
        libicu-dev \
        g++ \
        ## php-pgsql
        libpq-dev \
        ## php-ldap
        libldap2-dev \
        ## php-imagick
        libmagickwand-dev \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    #&& docker-php-ext-configure intl \
	&& docker-php-ext-install -j$(nproc) \
	    opcache \
        pdo_mysql \
        mysqli \
	    zip \
	    gd \
	    intl \
	    pdo_pgsql \
	    ldap \
    && pecl install \
        imagick \
        mongodb \
        apcu \
        xdebug \
    && docker-php-ext-enable \
        imagick \
        mongodb \
        apcu \
        xdebug

## Build and install the Uploadprogress PHP extension.
## See http://git.php.net/?p=pecl/php/uploadprogress.git
RUN curl -fsSL 'http://git.php.net/?p=pecl/php/uploadprogress.git;a=snapshot;h=95d8a0fd4554e10c215d3ab301e901bd8f99c5d9;sf=tgz' -o php-uploadprogress.tar.gz \
  && tar -xzf php-uploadprogress.tar.gz \
  && rm php-uploadprogress.tar.gz \
  && ( \
    cd uploadprogress-95d8a0f \
    && phpize \
    && ./configure --enable-uploadprogress \
    && make \
    && make install \
  ) \
  && rm -r uploadprogress-95d8a0f \
  && docker-php-ext-enable uploadprogress





## Imagemagick
RUN apt-get install -y --no-install-recommends \
        imagemagick






# SSH
RUN apt-get install -y --no-install-recommends \
    openssh-server

RUN mkdir \
    /var/run/sshd
    #/var/lock/apache2 \
    #/var/run/apache2 \
    #/var/log/supervisor

## ----------------------
## Enable SSH root access
## ----------------------
#RUN echo 'root:toor' | chpasswd \
#  && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
#  && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
#ENV NOTVISIBLE "in users profile"
#RUN echo "export VISIBLE=now" >> /etc/profile

## Enable SSH login
RUN sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN echo "${SSH_USER}:${SSH_PASSWD}" | chpasswd
RUN usermod -s /bin/bash ${SSH_USER}

## Set permissions
RUN chown -R www-data:www-data /var/www





## Multi-services
RUN apt-get install -y --no-install-recommends \
    supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf







## Wordpress
#RUN curl -fSL "https://wordpress.org/${WORDPRESS_VERSION}.tar.gz" -o wordpress.tar.gz \
#  && tar -xzf wordpress.tar.gz -C ${DOCROOT}/ \
#  && rm wordpress.tar.gz \
#  && chown -R www-data:www-data ${DOCROOT}/wordpress

## Drupal
## https://www.drupal.org/download-latest/zip
## https://www.drupal.org/download-latest/tar.gz
#RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
#  && mkdir ${DOCROOT}/drupal \
#  && tar -xz --strip-components=1 -f drupal.tar.gz -C ${DOCROOT}/drupal \
#  && rm drupal.tar.gz \
#  && chown -R www-data:www-data ${DOCROOT}/drupal

## Commerce Kickstart
#RUN curl -fSL "https://ftp.drupal.org/files/projects/commerce_kickstart-7.x-2.54-core.tar.gz" -o drupal.tar.gz \
#  && mkdir ${DOCROOT}/kick \
#  && tar -xz --strip-components=1 -f drupal.tar.gz -C ${DOCROOT}/kick \
#  && rm drupal.tar.gz \
#  && chown -R www-data:www-data ${DOCROOT}/kick





#VOLUME ['/home/user/workspace', '${WORKSPACE}', '/usr/local/etc/php/conf.d']



## Default home directory for www-data is /var/www
## Create home directory for existing user
#RUN usermod -m -d /home/www-data www-data
#RUN mkhomedir_helper www-data
# /var/www/html/public
# /var/www/drupal/public
# /var/www/wordpress/public





# Cleaning copied files (install and config)
COPY config/purge.sh /tmp/
RUN chmod u+x /tmp/purge.sh \
    && /tmp/purge.sh









# Default working directory
WORKDIR /var/www

## Enabled ports
## Apache 80
## SSH 22
## Samba 135 for End Point Mapper [DCE/RPC Locator Service], 137, 138 for nmbd and 139, 445 for smbd
#EXPOSE 80 22 135/tcp 137/udp 138/udp 139/tcp 445/tcp
EXPOSE 80 22 445



## Apache start
#CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

## SSH start
#CMD ["/usr/sbin/sshd", "-D"]

## Samba start
#CMD ["/usr/sbin/smbd", "-D"]

## Supervisor
CMD ["/usr/bin/supervisord"]
