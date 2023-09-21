# This is the example of the configuration file for specific environments.
# Please change the file name to the specific environment name and
# remove the ".ex" extension to make it a valid configuration file.

# set the port the application listening on
#
# the priority of this option is: app environment config > global config > cli config > default, which means:
#   - if the port is enabled here, those specified elsewhere will all be ignored
#   - if the port is specified nowhere, a default port will be used, which generally should be 4567.
# if 0 is given as the value for this option, the application will listen on a random availabe port
# 
#port: 4567