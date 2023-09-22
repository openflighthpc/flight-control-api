# flight-control-api
REST API to handle provider-agnostic cloud requests

# Configuration

This application uses YAML files to manage configurations. One of those files is `etc/config.yml`, which is the global configuration for the application. In addition to that, tje configuration can also be customized through individual configuration files for each specific running environment, such as development and production environments. This Section will start from the global `etc/config.yml`, and then discuss environment-specific configuration as well as explain the correlation between the global configuration and the specific environment configurations.

## Global Configuration

The global configuration is written in `etc/config.yml`. Along with the following configuration instructions, a [Global Configuration Example](etc/config.yml) is also given.

### Option: env

By default, as a Sinatra server, this application will be launched in the development environment. There are two ways to change this environment: set the `APP_ENV` environment variable or enable the `env` option in the global configuration. The option set in the global configuration has a higher priority than the `APP_ENV` environment variable. So once it is set, the environment variable will be ignored. The following statement provides an example of setting the environment to production:

```
env: production
```

With the above configuration, you should be able to see the following line when running the application:

```
# ...
*  Environment: production
# ...
```

This means that the application is now running in the production server. And the corresponding environment-specific configurations will also be applied.

### Option: development_config_path & production_config_path

Except for the global configuration, other configuration files can be placed under a customized path, which is specified by the `<environment>_config_path` option. Here the term "&lt;environment&gt;" should be changed to specific environment names. For example:

```
development_config_path: /path/to/development.yml
```

It is strongly recommended to use the absolute path as the value. If the option is not enabled, the application will by default try to find `etc/<environment>.yml`. which is the same path as the global configuration file. Again, the "&lt;environment&gt;" here means the specific environment names.

### Option: port

This option is to set the port the application listening on. It accepts an integer between 1024 and 65535, representing the available port number. By default, a Sinatra server will listening on the port 4567 without a specified port. In addition, it can also be set to 0, which will result in the application randomly choosing an available port. In this case, the port number will be unpredictable befor startup.

```
port: 4567
```

There are several places this parameter can be set. Please see [Global Configuration Example](etc/config.yml.ex) for detailed descriptions.

## Environment Specific Configuration

The environment-specific configuration files are used to customize the configurations for different environments. If the option is enable in both environment-specific configuration and global configuration, the environment-specific one will generally has a higher priority so that the global one will be ignored.

Since the functionalities of the available options have been discussed in the [Global Configuration Section](https://github.com/openflighthpc/flight-control-api#Global-Configuration), the following is a list of options that supported by environment specific configuration:
- port

An [Example Configuration File](etc/environment.yml.ex) has been provided.