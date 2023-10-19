# Start the given instance. Exit status 0 denotes success.
echo "Starting $INSTANCE_ID"
"$RUN_ENV/bin/yq_linux_amd64" -i '.state = "on"' "$RUN_ENV/projects/$PROJECT_NAME/nodes/$INSTANCE_ID.yaml"
