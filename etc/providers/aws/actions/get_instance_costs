#!/bin/bash

# Sort timestamps into start & end days
START=$(gdate -d @$START_TIME +%Y-%m-%d)
END=$(gdate -d @$END_TIME +%Y-%m-%d)

INSTANCE_LIST="$(echo "[\"$(echo $INSTANCE_IDS |sed 's/,/","/g' |tr -d '\n\t\r[:blank:][:space:]')\"]")"

OUT="[]"

for instance in $(echo "$INSTANCE_IDS" |sed 's/,/ /g') ; do
    costs=$(aws ce get-cost-and-usage-with-resources --time-period Start=$START,End=$END --granularity DAILY --metrics UnblendedCost --filter "{ \"Dimensions\": {\"Key\": \"RESOURCE_ID\", \"Values\": [\"$instance\"] } }"  --query 'ResultsByTime[].Total.UnblendedCost.Amount[]')
    total=$(echo "$costs" |jq '. | add')
    OUT=$(echo "$OUT" |jq ".[. |length] |= . + { \"instance_id\": \"$instance\", \"price\": $total, \"kwh\": \"UNKNOWN\"} " )
done

echo "$OUT"
