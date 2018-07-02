<?php

namespace Deployer;

use Deployer\Exception\Exception;

require 'recipe/common.php';

set('writable_use_sudo', '{{write_use_sudo}}');
set('writable_mode', 'chown'); // chmod, chown, chgrp or acl.
set('deploy_path', "{{deploy_path_custom}}");

// Magento root
set('magento_root', 'htdocs');

// Configuration
set(
    'shared_files', [
        '{{magento_root}}/app/etc/env.php',
        '{{magento_root}}/var/.maintenance.ip',
    ]
);
set(
    'shared_dirs', [
        '{{magento_root}}/pub/media',
    ]
);
set(
    'writable_dirs', [
        '{{magento_root}}/var',
        '{{magento_root}}/pub/static',
        '{{magento_root}}/pub/media',
    ]
);

// Servers
inventory('hosts.yml');

// Tasks
desc('Unpack bucket-commit');
task(
    'deploy:unpack-bucket', function() {
    try {
        cd('{{host_bucket_path}}');
        run('mkdir temp');
        run('tar xfz {{bucket-commit}} -C temp');
        run('cp -rf temp/htdocs {{release_path}}');
        run('cp -rf temp/pipelines {{deploy_path}}');
        run('mv {{bucket-commit}} {{bucket-commit}}.back');
        run('rm temp -rf');
    } catch (\Exception $e) {
        throw new Exception('No bucket-commit file found. '.$e->getMessage());
    }
}
);

// Main Tasks
desc('Deploy bucket');
task(
    'deploy-bucket', [
        'deploy:info',
        'deploy:prepare',
        'deploy:lock',
        'deploy:release',
        'deploy:unpack-bucket'
    ]
);

desc('Deploy release');
task(
    'deploy', [
        'deploy:shared',
        'deploy:writable',
        'deploy:symlink',
        'deploy:unlock',
        'cleanup',
        'success'
    ]
);

// [Optional] If deploy fails automatically unlock.
after('deploy:failed', 'deploy:unlock');
