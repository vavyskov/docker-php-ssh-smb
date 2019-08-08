#!/bin/bash

#set -eu

## Remove APT cache
echo -e "\nRemoving APT cache...\n"
apt-get clean -y
apt-get autoclean -y
apt-get autoremove -y
rm -r /var/lib/apt/lists/*

## Cleanup temporary, variable and source directory
echo -e "\nCleaning temporary directory...\n"
rm -rf /tmp/*
#rm -fr /tmp/.* 2> /dev/null
rm -rf /var/tmp/*
rm -rf /usr/src/*
#rm -rf /usr/src/linux-headers*
#rm -rf /usr/src/virtualbox-guest* /usr/src/virtualbox-ose-guest*
#rm -rf /usr/src/vboxguest*

## Cleanup log files "content" only
echo -e "Cleanup log files\n"
for logs in `find /var/log -type f`; do > $logs; done
## Remove old log archives
find /var/log/ -type f -regex '.*\.[0-9]+\.gz$' -delete

## -----------------------------------------------------------------------------

## Remove unused locales (edit for your needs, this keeps only en* and cs*)
#echo -e "\nRemoving unused locales...\n"
#find /usr/share/locale/* -type d ! -path '*/en*' ! -path '*/cs*' -print0 | xargs -r0 -- rm -r

## https://github.com/chef/bento/blob/master/debian/scripts/cleanup.sh
##
## aptitude clean
## cat /dev/zero > zero.fill;sync;sleep 1;sync;rm -f zero.fill

## Save a few more megabytes
#apt-get purge -y locate

## Delete any old dev libraries you likely won't need
#dpkg -l | grep -- '-dev' | xargs apt-get purge -y



## Remove documentation files
#echo -e "Remove documentation files\n"
#find /var/lib/doc -type f | xargs rm -f

## Remove bash history
#echo -e "Remove bash history\n"
#unset HISTFILE
#rm -f /root/.bash_history



## Whiteout root
#echo -e "Whiteout root\n"
#count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`;
#count=$((count -= 1))
#dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
#rm /tmp/whitespace;

## Whiteout /boot
#echo -e "Whiteout /boot\n"
#count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
#count=$((count -= 1))
#dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
#rm /boot/whitespace;

## Whiteout swap
#echo -e "Whiteout swap\n"
#swappart=$(cat /proc/swaps | grep -v Filename | tail -n1 | awk -F ' ' '{print $1}')
#if [ "$swappart" != "" ]; then
#  swapoff $swappart;
#  dd if=/dev/zero of=$swappart;
#  mkswap $swappart;
#  swapon $swappart;
#fi

## After swap cleaning, we need to set the proper UUID for swap in /etc/fstab.
## 'sudo blkid' will give you current swap UUID
## Edit /etc/fstab to have proper UUID.



#aptitude -y purge ri
#aptitude -y purge installation-report landscape-common wireless-tools wpasupplicant ubuntu-serverguide
#aptitude -y purge python-dbus libnl1 python-smartpm python-twisted-core libiw30
#aptitude -y purge python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl python-serial python-gobject python-pam python-openssl libffi5
#apt-get purge -y linux-image-3.0.0-12-generic-pae

## -----------------------------------------------------------------------------

## Fix disk fragmentation (increases compression efficiency)
#echo -e "\nFixing disk fragmentation (wait please)...\n"
##dd if=/dev/zero of=/EMPTY bs=1M status=progress
#dd if=/dev/zero of=/EMPTY bs=1M 2>/dev/null
#rm -f /EMPTY
