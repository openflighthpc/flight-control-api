#!/bin/bash 
set -e
echo "Preparing..."

mkdir -p $RUN_ENV/aws/cli/bin

temp_dir=$(mktemp -d)
cd $temp_dir

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" -s
unzip -qq awscliv2.zip
./aws/install -i $RUN_ENV/aws/cli/bin/cli/aws_cli -b $RUN_ENV/aws/cli/bin/
rm -rf $temp_dir

dnf -y install jq

echo "Prepared"
