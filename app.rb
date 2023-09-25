require 'sinatra'
require 'sinatra/config_file'
require "sinatra/custom_logger"
require 'logger'

config_file ENV['CONFIG_PATH'] || 'etc/config.yml'
set :bind, ENV['BIND'] if ENV['BIND']
set :port, ENV['PORT'] if ENV['PORT']

# initialize logger
if settings.respond_to?(:logging)
  ENV['LOG_PATH'] ||= settings.logging['path'] if settings.respond_to?(:logging)
  ENV['LOG_LEVEL'] ||= settings.logging['level'] if settings.respond_to?(:logging)
end
LOGGER = Logger.new(ENV['LOG_PATH'] || STDOUT)
log_levels = {
  'debug': Logger::DEBUG,
  'info': Logger::INFO, 
  'warn': Logger::WARN,
  'error': Logger::ERROR,
  'fatal': Logger::FATAL
}
LOGGER.level = log_levels[ENV['LOG_LEVEL']] if ENV['LOG_LEVEL']
disable :logging
use Rack::CommonLogger, LOGGER
set :logger, LOGGER

# rest apis
get '/ping' do
  'OK'
end
