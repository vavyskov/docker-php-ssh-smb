#!/bin/bash
set -eu

## Current script directory path
CURRENT_DIRECTORY=$(dirname $0)

## -----------------------------------------------------------------------------

## GLOBAL Drush (variant A)
curl -fsSL -o /usr/local/bin/drush https://github.com/drush-ops/drush/releases/download/8.3.0/drush.phar
chmod +x /usr/local/bin/drush

## GLOBAL Drush (variant B)
## apt-get install -y mysql-client
#COMPOSER_HOME=/opt/composer composer global require drush/drush:8
#ln -s /opt/composer/vendor/drush/drush/drush /usr/local/bin/drush

## Drush launcher
## https://github.com/drush-ops/drush-launcher




## Drupal console
curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal
chmod +x /usr/local/bin/drupal

## Drupal console launcher
## https://docs.drupalconsole.com/en/getting/launcher.html

## -----------------------------------------------------------------------------

## Services

