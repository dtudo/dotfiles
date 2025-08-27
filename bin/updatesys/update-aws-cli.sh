#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "> Updating AWS CLI..."

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws/

aws --version
printf '%s\n' "> AWS CLI update complete"
