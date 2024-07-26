#!/bin/bash

echo "this script now will setup local development environment"

rm -rf .configs
rm -rf .data
rm -rf .secrets
mkdir -p .configs/nginx
mkdir -p .data/logs
mkdir -p .secrets