#!/bin/bash

# Scope check?
if [[ ! -z ${SCOPE} ]] ; then
    # Project scope tagging
    FILTERS="--filters Name=tag:project,Values=$SCOPE"
fi

# Get instance list
aws ec2 describe-instances $FILTERS --query 'Reservations[].Instances[].{instance_id: InstanceId, model: InstanceType, region: "whydothishere?", state: State.Name, tags: {project: Tags[?Key==`project`]|[0].Value, type: Tags[?Key==`type`]|[0].Value}}' |tr -d '\n '

