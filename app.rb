require 'sinatra'
require 'sinatra/config_file'
require "sinatra/custom_logger"
require "sinatra/namespace"
require 'logger'
require_relative './lib/control_api'

config_file ENV['CONFIG_PATH'] || File.join(__dir__, 'etc/config.yml')

configure do
  set :bind, ENV['BIND'] if ENV['BIND']
  set :port, ENV['PORT'] if ENV['PORT']
  
  set :backend_config, Config.setup_singleton(provider_path: ENV['PROVIDER_PATH'] || (settings.respond_to?(:provider_path) ? settings.provider_path : nil))
end

# initialize logger
if settings.respond_to?(:log)
  ENV['LOG_PATH'] ||= settings.log['path']
  ENV['LOG_LEVEL'] ||= settings.log['level']
end
LOGGER = Logger.new(ENV['LOG_PATH'] || STDOUT)
log_levels = {
  'debug' => Logger::DEBUG,
  'info' => Logger::INFO, 
  'warn' => Logger::WARN,
  'error' => Logger::ERROR,
  'fatal' => Logger::FATAL
}
raise "Invalid log level" if ENV['LOG_LEVEL'] && !log_levels.key?(ENV['LOG_LEVEL'])
LOGGER.level = log_levels[ENV['LOG_LEVEL']] if ENV['LOG_LEVEL']
disable :logging
use Rack::CommonLogger, LOGGER
set :logger, LOGGER

# rest apis
get '/ping' do
  'OK'
end

namespace '/providers' do
  # get providers list
  get do
    Provider.all.map(&:to_hash).to_json
  end

  # get specific provider
  get '/:id' do
    id = params['id']
    return Provider[id].to_hash.to_json if Provider[id]
    404
  end
end
