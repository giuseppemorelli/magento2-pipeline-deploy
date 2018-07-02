#!/usr/bin/env bash

set -e

PROJECT_PATH="$(pwd)"

mkdir ~/.composer && cp ./pipelines/dataconfig/composer/auth.json ~/.composer/

cd $PROJECT_PATH/htdocs

/usr/local/bin/composer install --no-progress --prefer-dist
chmod +x bin/magento

bin/magento setup:install \
--admin-firstname=local \
--admin-lastname=local \
--admin-email=local@local.com \
--admin-user=local \
--admin-password=local123 \
--base-url=http://magento.build/ \
--backend-frontname=admin \
--db-host=mysql \
--db-name=magento \
--db-user=root \
--db-password=magento \
--use-secure=0 \
--use-rewrites=1 \
--use-secure-admin=0 \
--session-save=db \
--currency=EUR \
--language=en_US \
--timezone="Europe/Rome" \
--key=magento \
--cleanup-database

bin/magento deploy:mode:set developer

echo "**************************"
echo "START UNIT TESTS"
echo "**************************"
./vendor/bin/phpunit -c dev/tests/unit/phpunit.xml.dist