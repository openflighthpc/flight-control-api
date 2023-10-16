# List instance types for a provider. Must be a comma separated list.
"$RUN_ENV/bin/yq_linux_amd64" eval-all '[.]' instance_types/* -o=json
