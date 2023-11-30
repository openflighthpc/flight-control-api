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

wget -O $RUN_ENV/jq "https://github.com/jqlang/jq/releases/download/jq-1.7/jq-linux-amd64"
chmod +x $RUN_ENV/jq

echo "Prepared"
