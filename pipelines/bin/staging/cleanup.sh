#!/usr/bin/env bash

set -e

cd pipelines/deployer
composer install

# deploy bucket
./vendor/bin/dep deploy:unlock $ENV \
-o bucket-commit=$BUCKET_COMMIT \
-o host_bucket_path=$HOST_DEPLOY_PATH_BUCKET \
-o deploy_path_custom=$HOST_DEPLOY_PATH \
-o write_use_sudo=true