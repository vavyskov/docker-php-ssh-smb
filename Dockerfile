## Fix: Remove error building note "debconf: delaying package configuration, since apt-utils is not installed"

## Variables
ARG DEBIAN_VERSION=latest

## Base image
FROM debian:${DEBIAN_VERSION}

## Configuration
ENV WORKSPACE=/var/www/workspace
ENV DOCROOT=${WORKSPACE}/public
#ENV APACHE_RUN_USER www-data
#ENV APACHE_RUN_GROUP www-data
#ENV APACHE_LOG_DIR /var/log/apache2

ENV SSH_PASSWD=www-data

ENV WORDPRESS_VERSION=4.9.6
ENV DRUPAL_VERSION=8.5.4

## Instalation
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ## Apache
    apache2 \
#    libapache2-mpm-itk \
    ## SSH
    openssh-server \
    ## Multi-services
    supervisor \
    ## PHP
    php \
    ## Database connections
    php-mysql \
#    pdo_mysql \
#    mysqli \
    php-sqlite3 \
    php-pgsql \
    ## PHP extensions
    php-gd \
    libpng-dev \
    php-mbstring \
    php-opcache \
    php-xml \
    php-curl \
#    php-cli \
#    php-xdebug \
    ## Certificates
    ca-certificates \
    ## Development
    git \
    composer \
    mysql-client \
    ## Image tools
#    libjpeg-progs \
#    optipng \
#    gifsicle \
#    php-imagick \
    ## System tools
    mc \
    curl \
#    wget \
#    vim \
    zip \
    unzip \
    ## Language
    locales \
  && locale-gen cs_CZ.UTF-8 \
  && apt-get clean \
  && apt-get autoclean \
  && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/*

## debian.cz/users/localization.php
#RUN dpkg-reconfigure locales

RUN mkdir \
    #/var/lock/apache2 \
    #/var/run/apache2 \
    /var/run/sshd
    #/var/log/supervisor

## Apache configuration
COPY apache.conf /etc/apache2/sites-available/000-default.conf

## PHP configuration
COPY php.ini /etc/php/7.0/apache2/conf.d/
#COPY php.ini /usr/local/etc/php/conf.d/






## Database connection (Wordpress, Drupal)
#RUN docker-php-ext-install mysqli pdo_mysql

## Other extension
#RUN docker-php-ext-install gd opcache zip mbstring xml curl





# Enable clean URL and caching
RUN a2enmod rewrite expires





## ----------------------
## Enable SSH root access
## ----------------------
#RUN echo 'root:toor' | chpasswd \
#  && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
#  && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
#ENV NOTVISIBLE "in users profile"
#RUN echo "export VISIBLE=now" >> /etc/profile





## Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

## Workspace
RUN rm -rf /var/www/* \
  && mkdir -p ${DOCROOT} \
  && mkdir -p ${WORKSPACE}/private \
  && echo "Public folder" > ${DOCROOT}/index.html \
  && echo "<?php phpinfo();" > ${DOCROOT}/info.php

## Enable SSH login for user www-data
ARG SSH_PASSWD
RUN sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN echo "www-data:${SSH_PASSWD}" | chpasswd
RUN usermod -s /bin/bash www-data





## Crate home folder for user www-data
#RUN usermod -d /home/www-data www-data
#RUN mkhomedir_helper www-data





## Set permissions
RUN chown -R www-data:www-data /var/www





## Add user (password: user)
#RUN useradd user -p user -m -s /bin/bash
#RUN mkdir -p /home/user/workspace/public
#RUN chown -R user:user /home/user/workspace





## Composer (variant A)
# RUN apt install composer

## Composer (variant B)
#COPY --from=composer /usr/bin/composer /usr/local/bin/composer

## Composer (variant C)
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer





## GLOBAL Drush (variant A)
## RUN apt install mysql-client
RUN curl -fsSL -o /usr/local/bin/drush https://github.com/drush-ops/drush/releases/download/8.1.17/drush.phar \
  && chmod +x /usr/local/bin/drush

## GLOBAL Drush (variant B)
## RUN apt install mysql-client
#RUN COMPOSER_HOME=/opt/composer composer global require drush/drush:8 \
#  && ln -s /opt/composer/vendor/drush/drush/drush /usr/local/bin/drush





## Drupal console
RUN curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal \
  && chmod +x /usr/local/bin/drupal






# Setup XDebug.
#COPY xdebug-docker.ini /usr/local/etc/php/conf.d/
#RUN echo "zend_extension = '$(find / -name xdebug.so 2> /dev/null)'\n$(cat /usr/local/etc/php/conf.d/xdebug-docker.ini)" > /usr/local/etc/php/conf.d/xdebug-docker.ini
#RUN cp /usr/local/etc/php/conf.d/xdebug-docker.ini /etc/php5/cli/conf.d/





## Timezone
#ENV TIMEZONE = Europe/Prague
#RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
#    echo "${TIMEZONE}" > /etc/timezone

#ENV TIMEZONE = Europe/Prague
#RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo "${TIMEZONE}" > /etc/timezone

#RUN echo "Europe/Prague" > /etc/timezone
#RUN dpkg-reconfigure -f noninteractive tzdata





## Wordpress
RUN curl -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" -o wordpress.tar.gz \
  && tar -xzf wordpress.tar.gz -C ${DOCROOT}/ \
  && rm wordpress.tar.gz \
  && chown -R www-data:www-data ${DOCROOT}/wordpress

## Drupal
RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && mkdir ${DOCROOT}/drupal \
  && tar -xz --strip-components=1 -f drupal.tar.gz -C ${DOCROOT}/drupal \
  && rm drupal.tar.gz \
  && chown -R www-data:www-data ${DOCROOT}/drupal

## Commerce Kickstart
#RUN curl -fSL "https://ftp.drupal.org/files/projects/commerce_kickstart-7.x-2.54-core.tar.gz" -o drupal.tar.gz \
#  && mkdir ${DOCROOT}/kick \
#  && tar -xz --strip-components=1 -f drupal.tar.gz -C ${DOCROOT}/kick \
#  && rm drupal.tar.gz \
#  && chown -R www-data:www-data ${DOCROOT}/kick





#VOLUME ['/home/user/workspace', '${WORKSPACE}', '/usr/local/etc/php/conf.d']





# Default working directory
WORKDIR ${WORKSPACE}

## Enabled ports
EXPOSE 80 22





## Apache start
#CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

## SSH start
#CMD ["/usr/sbin/sshd", "-D"]

## Supervisor
CMD ["/usr/bin/supervisord"]
