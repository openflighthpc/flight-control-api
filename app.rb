require 'sinatra'
require 'sinatra/config_file'

config_file ENV['CONFIG_PATH'] || 'etc/config.yml'
set :bind, ENV['BIND'] || settings.bind
set :port, ENV['PORT'] || settings.port

get '/ping' do
  'OK'
end
