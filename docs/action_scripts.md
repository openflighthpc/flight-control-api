# Description

The document continues the discussion from the [Action Script section](https://github.com/openflighthpc/flight-control-api/tree/develop#app_env) in the README.md, listing the inputs and outputs for all the scripts that expected by the Flight Control API.

# Script: authorise_credentials

## Environment Variables

Since the field names for credentials required by different providers vary, the environment variable names that this script can obtain are defined through the 'required_credentials' property in the corresponding provider's `metadata.yaml` file. For other scripts that require credentials, they also follow this specification when fetching credential-related environment variables.

## Echoes

```
{
  "result": true # or false if the credentials is invalid
}
```

# Script: list_models

This script is used to retrieve a list of available instance models that offered by the provider. It does not require extra environment variables.

## Echoes

```
[
  't2.large',
  't3.medium',
  ...other model names
]
```

# Script: model_details

This script retrieves the details of given instance models.

## Environment Variables

- MODELS: A list of the names of instance models, seperated by comma, e.g. `t3.medium,t2.large`

## Echoes

```
[
  {
    "model": "mining_rig",
    "provider": "example-provider",
    "currency": "Bitcoin",
    "price_per_hour": 0.000123,
    "kilowatts_per_hour": 2,
    "cpu": 1,
    "gpu": 8192,
    "mem": 8.1632
  },
  ...details of other models
]
```

# Script: list_instances

This script retrieves the list of all instances in a certain project.

## Environment Variables

- SCOPE: The scope of the project

## Echoes

```
[
  {
    "instance_id":"login1",
    "model":"compute_small",
    "region":"Mars",
    "state":"on",
    "tags":[
      {"type":"login"}
    ]
  },
  {
    "instance_id":"cnode01",
    "model":"mining_rig",
    "region":"Metaverse",
    "state":"on",
    "tags":[
      {"type":"compute"}
    ]
  },
  ...more instances
]
```

# Script: instance_costs

This script retrieves the costs of a given list of instances during a specific period of time. The `START_TIME`, `END_TIME`, and the `INSTANCE_IDS` variables should have been validated before they are passed into the script. Therefore, The script itself generally does NOT need to care about whether the given values are in correct format, whether there are conflicts between them, and whether the given values exist.

## Environment Variables

- START_TIME: Unix timestamp
- END_TIME: Unix timestamp
- INSTANCE_IDS: IDs to get cost for, comma separated list

## Echoes

```
[
  {
    "instance_id":"login1",
    "price":"1.85183333333333333332",
    "kwh":".37036666666666666666"
  },
  {
    "instance_id":"cnode01",
    "price":".00022777549999999999",
    "kwh":"3.70366666666666666664"
  },
  ...more instances
]
```

# Script: instance_usages

This script retrieves the usages of a given list of instances during a specific period of time. The `START_TIME`, `END_TIME`, and the `INSTANCE_IDS` variables should have been validated before they are passed into the script. Therefore, The script itself generally does NOT need to care about whether the given values are in correct format, whether there are conflicts between them, and whether the given values exist.

## Environment Variables

- START_TIME: Unix timestamp
- END_TIME: Unix timestamp
- INSTANCE_IDS: IDs to get cost for, comma separated list

## Echoes

```
[
  {
    "instance_id":"login1",
    "average":"41.36",
    "last":"76.07"
  },
  {
    "instance_id":"cnode01",
    "average":"97.65",
    "last":"99.32"
  }
]
```

# Script: start_instance

This script triggers the commands to launch a given instance. The `INSTANCE_ID` variable should have been validated before they are passed into the script. Therefore, The script itself generally does NOT need to care about whether it in correct format,  and whether the instance exists.

## Environment Variables

- INSTANCE_ID: The id of the instance

## Echoes

This script does not return a specific JSON object. Instead, exiting the script with status code `0` indicates correct credentials. Any other exit status indicates otherwise.

# Script: stop_instance

This script triggers the commands to shut down a given instance. The `INSTANCE_ID` variable should have been validated before they are passed into the script. Therefore, The script itself generally does NOT need to care about whether it in correct format,  and whether the instance exists.

## Environment Variables

- INSTANCE_ID: The id of the instance

## Echoes

This script does not return a specific JSON object. Instead, exiting the script with status code `0` indicates correct credentials. Any other exit status indicates otherwise.