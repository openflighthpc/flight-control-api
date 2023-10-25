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
    schema:
      type: string
  - in: header
    name: Project-credentials
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


## Instance Details

Fetch the details of instances.

### Path

```
/providers/{provider-id}/instance-details
```

### GET

```
parameters:
  - in: path
    name: provider-id
    schema:
      type: string
  - in: query
    name: model
    schema:
      type: string
responses:
  200:
    description: Array of instance details
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

## List instances

Return a JSON list of instances existing for the given provider and credentials

### Path

```http request
/providers/{provider-id}/list-instances
```

### GET

```
parameters:
  - in: path
    name: provider-id
    schema:
      type: string
  - in: query
    name: scope
    schema:
      type: string
  - in: header
    name: Project-credentials
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
              name:
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

## Start instance

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
    schema:
      type: string
  - in: query
    name: scope
    schema:
      type: string
  - in: header
    name: Project-credentials
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

## Stop instance

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
    schema:
      type: string
  - in: query
    name: scope
    schema:
      type: string
  - in: header
    name: Project-credentials
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
