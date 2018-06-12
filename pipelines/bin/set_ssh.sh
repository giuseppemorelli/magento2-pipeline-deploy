#!/bin/bash

set -e

which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
eval $(ssh-agent -s)
mkdir ~/.ssh/ && echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa
mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
echo "$SSH_KEYSCAN" >> ~/.ssh/known_hosts