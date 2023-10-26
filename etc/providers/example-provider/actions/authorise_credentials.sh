#!/usr/bin/env bash

set -e

# This command will authorise credentials. Exit status 0 indicates correct credentials, any other exit status indicates otherwise.
# We also use this file to set up a fake backend 'project'.

project="$RUN_ENV/projects/$PROJECT_NAME"
if [ -d "$project" ]
then
  echo 'Credentials correct'
  exit 0
fi

echo "Creating project '$PROJECT_NAME'"
mkdir -p "$project"

nodes_dir="$project/nodes"
mkdir "$nodes_dir"

echo "Creating login1.yaml..."
cat <<EOF > "$nodes_dir/login1.yaml"
---
name: login1
state: on
tags:
  - type: login
EOF

for int in {01..03}
do
  name="cnode$int"
  echo "Creating $name.yaml..."

  cat <<EOF > "$nodes_dir/$name.yaml"
---
name: $name
state: on
tags:
    - type: compute_small
EOF
done

echo 'Credentials correct'
