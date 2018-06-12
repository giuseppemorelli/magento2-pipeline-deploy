#!/usr/bin/env bash

# check and edit this path (public path of magento)
cd /var/www/htdocs

echo "Import magento config"
php bin/magento app:config:import

################################################
# For more security we remove production       #
# data and lock configuration to env.php file  #
################################################

## ex.
## bin/magento config:set "web/secure/use_in_frontend" "0"
## bin/magento config:set "web/secure/use_in_adminhtml" "0"

# lock to env.php file

## bin/magento config:set --lock "web/secure/use_in_frontend" "0"
## bin/magento config:set --lock "web/secure/use_in_adminhtml" "0"

echo "Check setup:upgrade status"
# use --no-ansi to avoid color characters
message=$(php bin/magento setup:db:status --no-ansi)

if [[ ${message:0:3} == "All" ]]; then
  echo "No setup upgrade - clear cache";
  php bin/magento cache:clean
else
  echo "Run setup:upgrade - maintenance mode"
  php bin/magento maintenance:enable
  php bin/magento setup:upgrade --keep-generated
  php bin/magento maintenance:disable
  php bin/magento cache:flush
fi