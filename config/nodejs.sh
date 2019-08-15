#!/bin/bash
set -eu

## Current script directory path
CURRENT_DIRECTORY=$(dirname $0)

## -----------------------------------------------------------------------------

## Node.js (latest)
#curl -sL https://deb.nodesource.com/setup_11.x | bash -

## Node.js (LTS)
curl -sL https://deb.nodesource.com/setup_10.x | bash -

## Node.js
apt-get install -y --no-install-recommends nodejs

## -----------------------------------------------------------------------------

##
## JavaScript package management
##

## NPM (included in Node.js)

## YARN
npm install -g yarn

## PNPM
#npm install -g pnpm
## PNPM upgrade
#pnpm install -g pnpm

## -----------------------------------------------------------------------------

## Services
#service apache2 reload