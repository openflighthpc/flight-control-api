require 'sinatra'
require 'sinatra/config_file'
require_relative 'lib/config'

config_file ENV['CONFIG_PATH'] || 'etc/config.yml'

# set :environment, Config.env
# set :port, Config.port if Config.port

get '/ping' do
  'OK'
end
