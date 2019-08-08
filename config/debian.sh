#!/bin/bash
set -eu

## Current script directory path
CURRENT_DIRECTORY=$(dirname $0)

## -----------------------------------------------------------------------------

## Apt configuration
cat << EOF > /etc/apt/apt.conf.d/99minimal
Apt::Install-Recommends false;
Apt::Install-Suggests false;
Apt::AutoRemove::RecommendsImportant false;
Apt::AutoRemove::SuggestsImportant false;
EOF

## Language
apt-get install -y --no-install-recommends \
  locales
sed -i "s/# cs_CZ.UTF-8/cs_CZ.UTF-8/" /etc/locale.gen
dpkg-reconfigure --frontend=noninteractive locales
#update-locale LANG=cs_CZ.UTF-8
update-locale LANG=cs_CZ.UTF-8 LC_COLLATE=C

## NTP
apt-get install -y --no-install-recommends \
  ntp
#service ntp restart
##timedatectl set-timezone Europe/Prague
unlink /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Prague /etc/localtime

## Net Tools
#apt-get install -y --no-install-recommends \
#  net-tools
## Show port in use
#netstat -antp
#kill -9 <PID>

## -----------------------------------------------------------------------------

## Certificates
apt-get install -y --no-install-recommends \
  ca-certificates \
  openssl

## Configuration
apt-get install -y --no-install-recommends \
  debconf-utils

## System tools
apt-get install -y --no-install-recommends \
  wget \
  curl \
  zip \
  unzip \
  lsb-release
#apt-get install -y nmon



## Vim
apt-get install -y --no-install-recommends \
  vim
#cat << EOF > /etc/vim/vimrc.local
#syntax on
#set background=dark
#set esckeys
#set ruler
#set laststatus=2
#set nobackup
#autocmd BufNewFile,BufRead Vagrantfile set ft=ruby
#EOF



## MC
apt-get install -y --no-install-recommends \
  mc
#cp ./mc /etc/mc/
#cp ./mc ~/.config/

## use_internal_edit=1

#cp ./mc/.mc.ini /home/vagrant/
#chown vagrant:vagrant /home/vagrant/.mc.ini
#chmod -R -x /home/vagrant/.mc.ini

## Edit=%var{EDITOR:editor} %f
#cp -p ./mc/mc.ext /home/vagrant/.config/mc/
#chown vagrant:vagrant /home/vagrant/.config/mc/mc.ext
# chmod -R -x /home/vagrant/.config/mc/mc.ext

## -----------------------------------------------------------------------------

## Development
apt-get install -y --no-install-recommends \
  git

## -----------------------------------------------------------------------------

## E-mail transfer agent
debconf-set-selections <<< "postfix postfix/mailname string $(hostname -d)"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install -y --no-install-recommends \
  postfix
sed -i "s/inet_interfaces = all/inet_interfaces = loopback-only/" /etc/postfix/main.cf



## /etc/postfix/main.cf
##mydestination = $myhostname, localhost.$mydomain, $mydomain



##php.ini
#sendmail_path = /usr/bin/env catchmail -f devel@example.com

## -----------------------------------------------------------------------------

## Services
