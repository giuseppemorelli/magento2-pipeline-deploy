#!/usr/bin/env bash

# check and edit this path (public path of magento)
cd /var/www/htdocs

echo "Import magento config"
php bin/magento app:config:import

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