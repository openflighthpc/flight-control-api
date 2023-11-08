#!/bin/bash

# Scope check?
if [[ ! -z ${SCOPE} ]] ; then
    # Project scope tagging
    FILTERS="--filters Name=tag:project,Values=$SCOPE"
fi

# Get instance list
LIST=$(aws ec2 describe-instances $FILTERS --query 'Reservations[].Instances[].{instance_id: InstanceId, model: InstanceType, state: State.Name, tags: {project: Tags[?Key==`project`]|[0].Value, type: Tags[?Key==`type`]|[0].Value}}')

# Add region to list
LIST=$(echo "$LIST" |jq ".[] += { \"region\": \"$AWS_REGION\" }")

# Remove tags if not present (AWS returns the values for these as null)
LIST=$(echo "$LIST" |jq 'del(.. | select(. == null) )')

# Return 1 line response
echo "$LIST"  |tr -d '\n '
