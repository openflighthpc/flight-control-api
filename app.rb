require 'sinatra'
require 'yaml'
require_relative 'lib/config'

set :port, Config.port if Config.port

get '/*' do
  return [200, 'OK'] if params['splat'][0] == 'ping'
  redirect to('/ping')
end