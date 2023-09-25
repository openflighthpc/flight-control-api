require 'sinatra'
require 'sinatra/config_file'

config_file ENV['CONFIG_PATH'] || 'etc/config.yml'
set :bind, ENV['BIND'] if ENV['BIND']
set :port, ENV['PORT'] if ENV['PORT']

get '/ping' do
  'OK'
end
