# List instances for a given project, along with their tags. Output is JSON data.
"$RUN_ENV/bin/yq_linux_amd64" eval-all '[.]' "$RUN_ENV/instance_models/$MODEL.yaml" -o=json
