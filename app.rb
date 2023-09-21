require 'sinatra'
require_relative 'lib/config'

set :environment, Config.env
set :port, Config.port if Config.port

get '/*' do
  return [200, 'OK'] if params['splat'][0] == 'ping'
  redirect to('/ping')
end