# Stop the given instance. Exit status 0 denotes success.
echo "Stopping $INSTANCE_ID"
"$RUN_ENV/bin/yq_linux_amd64" -i '.state = "off"' "$RUN_ENV/projects/$PROJECT_NAME/nodes/$INSTANCE_ID.yaml"
