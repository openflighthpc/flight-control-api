# This is the example of the global configuration file.
# Please remove the ".ex" extension to make it a valid configuration file.

# set the environment the application will be running on.
#
# the priority of this option is: global config > ENV['APP_ENV'] > default, which means:
#  - if the option is enabled here, the system environment variable will be igored, including the APP_ENV='some environment' setting prepend in the CLI command.
#  - if neither the option is enabled nor the 'APP_ENV' system environment variable is set, a default environment will be used, which is development environment.
#
#env: production

# the absolute path to the config files for different environments.
# 
# if the option is not enabled, the paths will be /path/to/flight-control-api/etc/environment-name.yml by default.
# 
#development_config_path: C:/CenaCloudStorage/development.yml
#production_config_path: /path/to/production.yml

# set the port the application listening on.
#
# the priority of this option is: app environment config > global config > cli config > default, which means:
#   - if the port is defined in the config file for the corresponding environment, the option enabled here will be ignored.
#   - if the option is enabled here, the -p option appended in the CLI command will be ignored when starting the application from the console.
#   - if the port is specified nowhere, a default port will be used, which generally should be 4567.
# if 0 is given as the value for this option, the application will listen on a random availabe port.
#
#port: 4567