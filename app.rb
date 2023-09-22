require 'sinatra'
require 'sinatra/config_file'

config_file ENV['CONFIG_PATH'] || 'etc/config.yml'

get '/ping' do
  'OK'
end
