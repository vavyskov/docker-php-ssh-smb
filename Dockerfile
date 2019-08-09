## Fix: Remove error building note "debconf: delaying package configuration, since apt-utils is not installed"

## Variables
ARG DEBIAN_VERSION=latest
ARG WORKGROUP=VEVVA

## Base image
FROM debian:${DEBIAN_VERSION}

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

## Instalation
COPY config/* /tmp/
RUN chmod u+x /tmp/* \
    && /tmp/debian.sh \
    && /tmp/apache.sh \
    && /tmp/php.sh \
    && /tmp/samba.sh ${WORKGROUP} \
    && /tmp/drupal-tools.sh

## Apache configuration (Variable from script file does not work!)
COPY config/apache-dev.conf /etc/apache2/sites-available/000-default.conf

## Samba configuration (Variable from script file does not work!)
COPY config/smb.conf /etc/samba/smb.conf
## Add Samba user
RUN (echo ${SAMBA_PASSWD}; echo ${SAMBA_PASSWD}) | smbpasswd -s -a ${SAMBA_USER} 1>/dev/null



## PHP extension
#RUN docker-php-ext-install gd opcache zip mbstring xml curl





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
RUN /tmp/purge.sh









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

## Supervisor
CMD ["/usr/bin/supervisord"]
