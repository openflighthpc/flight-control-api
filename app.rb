require 'sinatra'

get '/*' do
  return [200, 'OK'] if params['splat'][0] == 'ping'
  redirect to('/ping')
end