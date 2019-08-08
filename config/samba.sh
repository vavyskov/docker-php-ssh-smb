#!/bin/bash
#set -eu
set -e

## Detect first parameter
if [[ -z $1 ]]; then
    WORKGROUP=WORKGROUP
else
    WORKGROUP=$1
fi

HOSTNAME=$(hostname)

## Current script directory path
#CURRENT_DIRECTORY=$(dirname $0)

## -----------------------------------------------------------------------------

# Samba instalation
apt-get install -y --no-install-recommends \
  libcups2 \
  samba \
  samba-common \
  cups
  #smbfs

## Samba configuration
## https://www.howtoforge.com/tutorial/debian-samba-server/
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

## FixMe: Variable ${WORKGROUP} does not work!
#cat << EOF > /etc/samba/smb.conf
#[global]
#workgroup = ${WORKGROUP}
#server string = Samba Server %v
#netbios name = ${HOSTNAME}
#security = user
#map to guest = bad user
#dns proxy = no
#
#[homes]
#   comment = Home Directories
#   browseable = no
#   valid users = %S
#   writable = yes
#   create mask = 0700
#   directory mask = 0700
#EOF

## Add Samba user
#(echo ${SAMBA_PASSWD}; echo ${SAMBA_PASSWD}) | smbpasswd -s -a ${SAMBA_USER} 1>/dev/null
