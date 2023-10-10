#!/bin/bash

# Scope check?
if [[ ! -z ${SCOPE} ]] ; then
    # Project scope tagging
    FILTERS="--filters 'Name=tag:project,Values=$SCOPE"
fi

# Get instance list
aws ec2 describe-instances $FILTERS --query 'Reservations[].Instances[].{name: Tags[?Key==`Name`]|[0].Value, id: InstanceId, type: InstanceType, state: State.Name, tags: {project: Tags[?Key==`project`]|[0].Value, type: Tags[?Key==`type`]|[0].Value}}' |tr -d '\n '

# Returns '[{"name": "instance_name", "id", "instance_id", "type": "instance_type", "state": "instance_state", "tags": { "project": "project_name_or_null", "type": "type_or_null" } }]'

echo '[{"name": "instance1", "tags": ["tag1", "tag2"]}, {"name": "instance2", "tags": ["tag1", "tag3"]}]'
