# flight-control-api
REST API to handle provider-agnostic cloud requests

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

## YAML Configuration

This application uses `Sinatra::ConfigFile` to read configurations from the YAML configuration file. As mentioned before, the path to the file can be set by the environment variable. Otherwise, the application will try to find and read the `etc/config.yml` if the path is not given.

In addition to the [Sinatra Config File Documentation](https://sinatrarb.com/contrib/config_file), an [example of the configuration file](etc/config.yml.ex) along with the instructions is also provided.

It could be found in the above example file that some options can be set by both environment variables and YAML configuration file. In this case, the values of the environment variables will be applied.

## Addition

The above approaches are recommended for configuring this application and should be sufficient to accommodate different scenarios. However, there might be other configuration approaches delivered alongside the underlying components of this application. Please note that they are not officially tested and might cause unexpected error.

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
