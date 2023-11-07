#!/bin/bash

# Scope check?
if [[ ! -z ${SCOPE} ]] ; then
    # Project scope tagging
    FILTERS="--filters Name=tag:project,Values=$SCOPE"
fi

# Get instance list
LIST=$(aws ec2 describe-instances $FILTERS --query 'Reservations[].Instances[].{instance_id: InstanceId, model: InstanceType, state: State.Name, tags: {project: Tags[?Key==`project`]|[0].Value, type: Tags[?Key==`type`]|[0].Value}}' |tr -d '\n ')

# Add region to list
echo "$LIST" |jq ".[] += { \"region\": \"$AWS_REGION\" }"

