# This command will authorise credentials. Exit status 0 indicates correct credentials, any other exit status indicates otherwise.
if ! aws sts get-caller-identity > /dev/null 2>&1 ; then
    echo "AWS account not connected to CLI"
    echo "Run aws configure to connect your account"
    exit 1
fi
