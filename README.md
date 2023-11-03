# Flight Control API
REST API to handle provider-agnostic cloud requests

# Overview

Flight Control API exists to collect a set of common cloud data-points together into a provider-agnostic API.

Projects in Flight Control regularly ask questions such as:

- Which instances are currently running?
- Which instances are _not_ running?
- How much has this instance cost me between these two dates?
- What is the current/historic CPU utilisation of this instance?
- How much does it cost per hour to run an instance of type `<type>`?

All of these questions have completely different approaches and answers depending on which cloud provider you're using. The goal of Flight Control API is to abstract these provider-specific approaches behind an interface that treats all projects the same.

# Setup

- Clone this repository
- Ensure the Ruby version specified in `.ruby-version` is installed with your favourite Ruby version manager
- If running in production:
  - Set `APP_ENV` environment variable to `production`
- Run `bundle install`

# Components

External components, including external scripts and description files, can be added to this application. This section explain the purposes and usage of each component.

## Provider

The providers can be regarded as a set of folders representing cloud service providers, where each folder corresponds to one cloud service provider. The folder names of these providers will be loaded by Flight Control as provider ids. Each folder contains a YAML file named 'metadata.yaml' to describe the attributes of that cloud service provider. The metadata files of different cloud service providers should have the same structure, i.e. same attributes. By default, Flight Control takes [etc/providers](etc/providers) as the default path to search for the available providers, in which an example provider folder containing the metadata.yaml is given as a template.

Each provider has a set of action scripts that it will use for common API use-cases. Please see the [example provider](etc/providers/example-provider) for a specification of required scripts. All scripts must be executable and include a shebang.

# Operation

The application is designed to work out of the box. Customisation options are available in [etc/config.yaml.ex](etc/config.yaml.ex).

Run the application with `ruby app.rb`. Access the application at `http://localhost:4567`:

# Configuration

The configuration of this application consists of two parts: one is environment variables configuration, and the other is YAML file configuration. This section will explain the specifics of these two configuration approaches.

## Environment Configuration

Some configuration options of this application are managed by environment variables. The statement below provides an example of setting environment variables while launching the application using CLI commands on a Linux system:

```
MY_OPTION=MY_VALUE ruby app.rb
```

The details of available options are listed in the coming sections.

### APP_ENV

`APP_ENV` is used to specify the environment in which the application will run. For instance, to launch the server in the production environment:

```
APP_ENV=production ruby app.rb
```

In this case, the server will run in the production server, and the relevant production configurations customized in the [YAML configuration file](https://github.com/openflighthpc/flight-control-api#YAML-Configuration) will be enabled.

If this option is not given, as a Sinatra server, this application will be launched in the development environment by default.

### CONFIG_PATH

`CONFIG_PATH` is used to specify the path to the [YAML configuration file](https://github.com/openflighthpc/flight-control-api#YAML-Configuration). It is strongly recommended to use the absolute path as the value, as demonstrated below:

```
CONFIG_PATH=/path/to/config.yml ruby app.rb
```

### BIND & PORT

`BIND` and `PORT` are used to specify the IP address and the port the application will be listening on. For example, to set the application to listen on `127.0.0.1:8888`:

```
BIND=127.0.0.1 PORT=8888 ruby app.rb
```

If these two variables are not given, the application will listen on `127.0.0.1:4567` for development environment and `0.0.0.0:4567` for production environment as the Sinatra default settings.

### LOG_PATH & LOG_LEVEL

By default, this application will print the log texts to the console. These two environment variables can be used to change the default behavior of the logger. See the following demonstration:

```
LOG_PATH=/path/to/app.log LOG_LEVEL=error app ruby.rb
```

With the above configuration, the texts will no longer be output to the console but written in the `/path/to/app.log` file.

For the logging level, this application use the `logger` as the logging management tool, which supports the following levels:

- debug
- info
- warn
- error
- fatal

### PROVIDER_PATH

By default, this application will load providers from `etc/providers`. This path can be changed by the `PROVIDER_PATH` environment variable.

```
PROVIDER_PATH=/path/to/providers app ruby.rb
```

## YAML Configuration

This application uses `Sinatra::ConfigFile` to read configurations from the YAML configuration file. As mentioned before, the path to the file can be set by the environment variable. Otherwise, the application will try to find and read the `etc/config.yml` if the path is not given.

In addition to the [Sinatra Config File Documentation](https://sinatrarb.com/contrib/config_file), an [example of the configuration file](etc/config.yml.ex) along with the instructions is also provided.

It could be found in the above example file that some options can be set by both environment variables and YAML configuration file. In this case, the values of the environment variables will be applied.

## Addition

The above approaches are recommended for configuring this application and should be sufficient to accommodate different scenarios. However, there might be other configuration approaches delivered alongside the underlying components of this application. Please note that they are not officially tested and might cause unexpected error.

# Action Scripts

This application itself does not provide algorithms for retrieving information from different cloud service providers. Instead, it relies on external scripts. Therefore, each provider directory under the [provider path](https://github.com/openflighthpc/flight-control-api#PROVIDER_PATH) contains a subfolder named 'actions' to store these scripts.

For a request, the Flight Control API first processes the received parameters, passes the relevant ones to the action scripts as environment variables. These scripts utilize these environment variables to retrieve requested information from the provider and return a JSON object in a specific structure. This section outlines all the necessary actions for this application, the environment variables passed to them, and their return format specifications.

## Script: authorise_credentials

### Environment Variables

Since the field names for credentials required by different providers vary, the environment variable names that this script can obtain are defined through the 'required_credentials' property in the corresponding provider's `metadata.yaml` file. For other scripts that require credentials, they also follow this specification when fetching credential-related environment variables.

### Echoes

This script does not return a specific JSON object. Instead, exiting the script with status code `0` indicates correct credentials. Any other exit status indicates otherwise.

## Script: list_models

This script is used to retrieve a list of available instance models that offered by the provider. It does not require extra environment variables.

### Echoes

```
[
  't2.large',
  't3.medium',
  ...other model names
]
```

## Script: model_details

This script retrieves the details of given instance models.

### Environment Variables

- MODELS: A list of the names of instance models, seperated by comma, e.g. `t3.medium,t2.large`

### Echoes

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

## Script: list_instances

This script retrieves the list of all instances in a certain project.

### Environment Variables

- SCOPE: The scope of the project

### Echoes

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

## Script: instance_costs

This script retrieves the costs of a given list of instances during a specific period of time. The `START_TIME`, `END_TIME`, and the `INSTANCE_IDS` variables should have been validated before they are passed into the script. Therefore, The script itself generally does NOT need to care about whether the given values are in correct format, whether there are conflicts between them, and whether the given values exist.

### Environment Variables

- SCOPE: The scope of the project
- START_TIME: Unix timestamp
- END_TIME: Unix timestamp
- INSTANCE_IDS: IDs to get cost for, comma separated list

### Echoes

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

## Script: instance_usages

This script retrieves the usages of a given list of instances during a specific period of time. The `START_TIME`, `END_TIME`, and the `INSTANCE_IDS` variables should have been validated before they are passed into the script. Therefore, The script itself generally does NOT need to care about whether the given values are in correct format, whether there are conflicts between them, and whether the given values exist.

### Environment Variables

- SCOPE: The scope of the project
- START_TIME: Unix timestamp
- END_TIME: Unix timestamp
- INSTANCE_IDS: IDs to get cost for, comma separated list

### Echoes

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

## Script: start_instance

This script triggers the commands to launch a given instance. The `INSTANCE_ID` variable should have been validated before they are passed into the script. Therefore, The script itself generally does NOT need to care about whether it in correct format,  and whether the instance exists.

### Environment Variables

- SCOPE: The scope of the project
- INSTANCE_ID: The id of the instance

### Echoes

This script does not return a specific JSON object. Instead, exiting the script with status code `0` indicates correct credentials. Any other exit status indicates otherwise.

## Script: stop_instance

This script triggers the commands to shut down a given instance. The `INSTANCE_ID` variable should have been validated before they are passed into the script. Therefore, The script itself generally does NOT need to care about whether it in correct format,  and whether the instance exists.

### Environment Variables

- SCOPE: The scope of the project
- INSTANCE_ID: The id of the instance

### Echoes

This script does not return a specific JSON object. Instead, exiting the script with status code `0` indicates correct credentials. Any other exit status indicates otherwise.

# REST API

To use this application, simply access the REST API paths listed below through your web browser.

## Ping test

Testing the connection to the server.

### Path

```
/ping
```

### GET

```
responses:
  200:
    description: Successful connection test
    content:
      text/plain:
        schema:
          type: string
```

## List Providers

List the information of all the available providers

### Path

```
/providers
```

### GET

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

## Fetch Provider

Fetch the information of a specific provider by id.

### Path

```
/providers/{provider-id}
```

### GET

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

## Validate Credentials

Verify the credential of the project.

### Path

```
/providers/{provider-id}/validate-credentials
```

### POST

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
  description: Dict of credential key/value pairs to validate
  required: true
  content:
    application/json:
      schema:
        credentials:
          type: object
responses:
  200:
    description: The given credentials are valid
  400:
    description: Malformed JSON request body
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Provider doesn't exist
```

## List Models

Fetch the details of instance models.

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
  404:
    description: Provider doesn't exist
  500:
    description: Internal server error
```

## Model Details

Fetch the details of instance models.

### Path

```
/providers/{provider-id}/model-details
```

### GET

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
              currency:
                type: string
              price_per_hour:
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
  404:
    description: Provider doesn't exist
  500:
    description: Internal server error
```

## List Instances

Return a JSON list of instances existing for the given provider and credentials

### Path

```http request
/providers/{provider-id}/instances
```

### GET

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
              tags:
                type: array
                items:
                  type: object
  401:
    description: The given credentials are either invalid or are missing keys
  404:
    description: Provider does not exist
  500:
    description: Internal server error
```

## Instance Usages

Return the average during the given period and the last recorded usage of the instance in percentage.

### Path

```http request
/providers/{provider-id}/instance-usages
```

### GET

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

## Start Instance

Attempt to start an instance existing on the provider.

### Path

```http request
/providers/{provider-id}/start-instance
```

### POST

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

## Stop Instance

Attempt to stop an instance existing on the provider.

### Path

```http request
/providers/{provider-id}/stop-instance
```

### POST

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

## Instance Costs

Return a JSON object of instances with their monetary costs and energy usage between two dates.

### Path

```http request
/providers/{provider-id}/instance-costs
```

### GET

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
  - in: query
    name: instance_ids
    collectionFormat: csv
    schema:
      type: string
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
                price:
                  type: float
                kwh:
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

# Troubleshooting

This section collects some potential errors that may be raised while running this application, along with the corresponding solutions.

## config_file.rb:148:in 'config_for_env': undefined method 'each_with_object'

This error may occur at the server startup, which could be caused by an existing but empty YAML configuration file. The complete error message may be displayed in the following form:
```
/path/to/sinatra-contrib-3.1.0/lib/sinatra/config_file.rb:148:in `config_for_env': undefined method `each_with_object' for false:FalseClass (NoMethodError)

      hash.each_with_object(IndifferentHash[]) do |(k, v), acc|
          ^^^^^^^^^^^^^^^^^
        from C:/Ruby32-x64/lib/ruby/gems/3.2.0/gems/sinatra-contrib-3.1.0/lib/sinatra/config_file.rb:127:in `block (3 levels) in config_file'
        from <internal:dir>:220:in `glob'
        from C:/Ruby32-x64/lib/ruby/gems/3.2.0/gems/sinatra-contrib-3.1.0/lib/sinatra/config_file.rb:121:in `block (2 levels) in config_file'
        from C:/Ruby32-x64/lib/ruby/gems/3.2.0/gems/sinatra-contrib-3.1.0/lib/sinatra/config_file.rb:120:in `each'
        from C:/Ruby32-x64/lib/ruby/gems/3.2.0/gems/sinatra-contrib-3.1.0/lib/sinatra/config_file.rb:120:in `block in config_file'
        from C:/Ruby32-x64/lib/ruby/gems/3.2.0/gems/sinatra-contrib-3.1.0/lib/sinatra/config_file.rb:119:in `chdir'
        from C:/Ruby32-x64/lib/ruby/gems/3.2.0/gems/sinatra-contrib-3.1.0/lib/sinatra/config_file.rb:119:in `config_file'
        from C:/Ruby32-x64/lib/ruby/gems/3.2.0/gems/sinatra-3.1.0/lib/sinatra/base.rb:2039:in `block (2 levels) in delegate'
        from app.rb:4:in `<main>'
```
To resolve this issue, please keep at least one line uncommented in the YAML file. As a recommendation, a minimal YAML file can have the following content:
```
develop:
```

# Copyright and License

Eclipse Public License 2.0, see LICENSE.txt for details.

Copyright (C) 2023-present Alces Flight Ltd.

This program and the accompanying materials are made available under the terms of the Eclipse Public License 2.0 which is available at https://www.eclipse.org/legal/epl-2.0, or alternative license terms made available by Alces Flight Ltd - please direct inquiries about licensing to licensing@alces-flight.com.

Flight Control API is distributed in the hope that it will be useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more details.
