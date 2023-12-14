# Ping test

Testing the connection to the server.

## Path

```
/ping
```

## GET

```
responses:
  200:
    description: Successful connection test
    content:
      text/plain:
        schema:
          type: string
```

# List Providers

List the information of all the available providers

## Path

```
/providers
```

## GET

```
responses:
  200:
    description: List of providers
    content:
      application/json:
        schema:
           type: array
           items:
             type: object
             properties:
               id:
                 type: string
```

# Fetch Provider

Fetch the information of a specific provider by id.

## Path

```
/providers/{provider-id}
```

## GET

```
parameters:
  - in: path
    name: provider-id
    required: true
    schema:
      type: string
responses:
  200:
    description: Provider specification
    content:
      application/json:
        schema:
          type: object
          properties:
            id:
              type: string
  404:
    description: Provider doesn't exist
```

# Validate Credentials

Verify the credential of the project.

## Path

```
/providers/{provider-id}/validate-credentials
```

## POST

```
parameters:
  - in: path
    name: provider-id
    required: true
    schema:
      type: string
  - in: header
    name: Project-Credentials
    required: true
    schema:
      type: object
responses:
  200:
    description: The given credentials are valid
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Provider doesn't exist
  500:
    description: Internal server error
```

## List Models

Fetch the array containing the name of instance models.

### Path

```
/providers/{provider-id}/models
```

### GET

```
parameters:
  - in: path
    name: provider-id
    required: true
    schema:
      type: string
  - in: header
    name: Project-Credentials
    required: true
    schema:
      type: object
responses:
  200:
    description: Array of model details
    content:
      application/json:
        schema:
          type: array
            items:
              description: the name of the model
              type: string
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Provider doesn't exist
  500:
    description: Internal server error
```

# Model Details

Fetch the details of instance models.

## Path

```
/providers/{provider-id}/model-details
```

## GET

```
parameters:
  - in: path
    name: provider-id
    required: true
    schema:
      type: string
  - in: query
    name: models
    required: true
    collectionFormat: csv
    schema:
      type: string
  - in: header
    name: Project-Credentials
    required: true
    schema:
      type: object
responses:
  200:
    description: Array of model details
    content:
      application/json:
        schema:
          type: array
          items:
            type: object
            properties:
              model:
                description: The name of the fixed instance size choice offered by providers, e.g. "t3.medium"
                type: string
              provider:
                type: string
              financial_data:
                type: object
                properties:
                  currency:
                    type: string
                    enum:
                      - GBP
                      - USD
                  price_per_hour:
                    type: float
              eco_data:
                type: object
                properties:
                  perspective:
                    type: string
                    enum:
                      - energy_consumption
                      - carbon_emission
                  unit:
                    type: string
                  max_amount_per_hour:
                    type: float
              cpu:
                description: the number of CPUs
                type: integer
              gpu:
                description: the number of GPUs
                type: integer
              mem:
                description: total memory
                type: integer
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Provider or model doesn't exist
  500:
    description: Internal server error
```

# List Instances

Return a JSON list of instances existing for the given provider and credentials

## Path

```http request
/providers/{provider-id}/instances
```

## GET

```
parameters:
  - in: path
    name: provider-id
    required: true
    schema:
      type: string
  - in: query
    name: scope
    schema:
      type: string
  - in: header
    name: Project-Credentials
    required: true
    schema:
      type: object
responses:
  200:
    description: Array of instances
    content:
      application/json:
        schema:
          type: array
          items:
            type: object
            properties:
              instance_id:
                type: string
              model:
                description: The name of the fixed instance size choice offered by providers, e.g. "t3.medium"
                type: string
              region:
                type: string
              state:
                type: string
                enum:
                  - on
                  - off
                  - unknown
              tags:
                type: object
                additionalProperties:
                  type: string
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Provider does not exist
  500:
    description: Internal server error
```

# Instance Usages

Return the average during the given period and the last recorded usage of the instance in percentage.

## Path

```http request
/providers/{provider-id}/instance-usages
```

## GET

```
parameters:
  - in: path
    name: provider-id
    required: true
    schema:
      type: string
  - in: query
    name: instance_ids
    required: true
    collectionFormat: csv
    schema:
      type: string
  - in: query
    description: The timestamp of the start of the time range, accurate to seconds
    name: start_time
    required: true
    schema:
      type: long
  - in: query
    description: The timestamp of the end of the time range, accurate to seconds
    name: end_time
    required: true
    schema:
      type: long
  - in: header
    name: Project-Credentials
    required: true
    schema:
      type: object
responses:
  200:
    description: Instance usage
    content:
      application/json:
        schema:
          start_time:
            type: long
          end_time:
            type: long
          usages:
            type: array
            items:
              type: object
              properties:
                instance_id:
                  type: string
                average:
                  description: The average usage of the given instance during the given period 
                  type: float
                last:
                  description: The last recorded usage of the given instance
                  type: float
  400:
    description: Missing instance_ids, start_time, or end_time parameters, or passing malformed parameters
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Provider does not exist or instance not found
  500:
    description: Internal server error
```

# Start Instance

Attempt to start an instance existing on the provider.

## Path

```http request
/providers/{provider-id}/start-instance
```

## POST

```
parameters:
  - in: path
    name: provider-id
    required: true
    schema:
      type: string
  - in: header
    name: Project-Credentials
    required: true
    schema:
      type: object
requestBody:
  description: Instance name to switch on
  content:
    application/json:
      schema:
        instance_id:
          type: string
responses:
  200:
    description: The instance was started successfully
  400:
    description: Malformed JSON request body
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Provider does not exist or instance not found
  500:
    description: Internal server error
```

# Stop Instance

Attempt to stop an instance existing on the provider.

## Path

```http request
/providers/{provider-id}/stop-instance
```

## POST

```
parameters:
  - in: path
    name: provider-id
    required: true
    schema:
      type: string
  - in: header
    name: Project-Credentials
    required: true
    schema:
      type: object
requestBody:
  description: Instance name to switch off
  content:
    application/json:
      schema:
        instance_id:
          type: string
responses:
  200:
    description: The instance was stopped successfully
  400:
    description: Malformed JSON request body
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Provider does not exist or instance not found
  500:
    description: Internal server error
```

# Instance Costs

Return a JSON object of instances with their monetary costs and energy usage between two dates.

## Path

```http request
/providers/{provider-id}/instance-costs
```

## GET

```
parameters:
  - in: path
    name: provider-id
    required: true
    schema:
      type: string
  - in: query
    name: instance_ids
    schema:
      type: string
    collectionFormat: csv
  - in: query
    name: start_time
    schema:
      type: long
  - in: query
    name: end_time
    schema:
      type: long
  - in: header
    name: Project-Credentials
    required: true
    schema:
      type: object
responses:
  200:
    description: Object describing instances
    content:
      application/json:
        schema:
          start_time:
            type: long
          end_time:
            type: long
          usages:
            type: array
            items:
              type: object
              properties:
                instance_id:
                  type: string
                financial_data:
                  type:object
                  properties:
                    currency:
                      type: string
                      enum:
                      - GBP
                      - USD
                    price:
                      type: float
                eco_data:
                  type:object
                  properties:
                    perspective:
                      type: string
                      enum:
                        - energy_consumption
                        - carbon_emission
                    unit:
                      type: string
                    amount:
                      type: float
  400:
    description: The given start/end dates are invalid
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Any number of given instance IDs do not exist
  500:
    description: Internal server error
```
