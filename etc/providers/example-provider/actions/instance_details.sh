# List instances for a given project, along with their tags. Output is JSON data.
result = $("$RUN_ENV/bin/yq_linux_amd64" eval-all '[.]' "$RUN_ENV/projects/$PROJECT_NAME/detailed_nodes"/*)
done
