aws ec2 describe-instance-types --query 'InstanceTypes[*].InstanceType' | tr -d '\n\t\r ' |sed 's/"//g;s/\[//g;s/\]//g'
