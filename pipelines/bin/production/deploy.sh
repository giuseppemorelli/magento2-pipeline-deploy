#!/usr/bin/env bash

set -e

cd pipelines/deployer
composer install

# deploy bucket
./vendor/bin/dep deploy-bucket $ENV \
-o bucket-commit=$BUCKET_COMMIT \
-o host_bucket_path=$HOST_DEPLOY_PATH_BUCKET \
-o deploy_path_custom=$HOST_DEPLOY_PATH \
-o write_use_sudo=true

# setup magento
ssh $USER@$HOST "cd $HOST_DEPLOY_PATH/release/htdocs/ && /bin/sh $HOST_DEPLOY_PATH/pipelines/bin/$ENV/bin/release_setup.sh"

# deploy release
./vendor/bin/dep deploy $ENV \
-o bucket-commit=$BUCKET_COMMIT \
-o host_bucket_path=$HOST_DEPLOY_PATH_BUCKET \
-o deploy_path_custom=$HOST_DEPLOY_PATH \
-o write_use_sudo=true

ssh $USER@$HOST "cd $HOST_DEPLOY_PATH/current/htdocs/ && /bin/sh $HOST_DEPLOY_PATH/pipelines/$ENV/bin/post_release_setup.sh"