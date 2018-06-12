#!/usr/bin/env bash

set -e

service mysql start

PROJECT_PATH="$(pwd)"

## de-comment and add auth.json for composer if you need
## mkdir ~/.composer && cp ./pipelines/dataconfig/composer/auth.json ~/.composer/

cd $PROJECT_PATH/htdocs

/usr/local/bin/composer install --no-dev --no-progress
chmod +x bin/magento

mysql -u root -e "DROP DATABASE IF EXISTS magento"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS magento"
mysql -u root -e "FLUSH PRIVILEGES"

bin/magento setup:install \
--admin-firstname=local \
--admin-lastname=local \
--admin-email=local@local.com \
--admin-user=local \
--admin-password=local123 \
--base-url=http://magento.build/ \
--backend-frontname=admin \
--db-host=localhost \
--db-name=magento \
--db-user=root \
--use-secure=0 \
--use-rewrites=1 \
--use-secure-admin=0 \
--session-save=db \
--currency=EUR \
--language=en_US \
--timezone="Europe/Rome" \
--key=magento \
--cleanup-database

git checkout -- dev/tools/grunt/configs/themes.js

bin/magento deploy:mode:set --skip-compilation production
bin/magento setup:static-content:deploy
## if you have problem with languages just use single command for every template like this
## bin/magento setup:static-content:deploy it_IT -f -s standard -t your-theme
## bin/magento setup:static-content:deploy en_US -f -s standard -t your-theme
## bin/magento setup:static-content:deploy it_IT -f -s standard -a adminhtml
## bin/magento setup:static-content:deploy en_US -f -s standard -a adminhtml

bin/magento setup:di:compile
composer dump-autoload --optimize

cd $PROJECT_PATH

tar cfz "$BUCKET_COMMIT" pipelines/bin/$ENV htdocs
scp "$BUCKET_COMMIT" $USER@$HOST:$HOST_DEPLOY_PATH_BUCKET