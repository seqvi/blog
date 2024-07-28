#!/bin/bash

echo "this script now will setup local development environment"

configs='.configs'
data='.data'
secrets='.secrets'
subj='/C=RU/ST=None/L=None/O=seqvi/CN=localhost.local'

# clear folder structure
rm -rf $configs
rm -rf $data
rm -rf $secrets
# make new folder structure
mkdir -p $configs/nginx
mkdir -p $data/logs
mkdir -p $secrets/nginx

# produce new TLS cert and key for https connections
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $secrets/nginx/nginx-selfsigned.key -out $secrets/nginx/nginx-selfsigned.crt -subj $subj