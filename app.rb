require 'sinatra'
require 'sinatra/config_file'
require "sinatra/custom_logger"
require 'logger'

config_file ENV['CONFIG_PATH'] || 'etc/config.yml'
set :bind, ENV['BIND'] if ENV['BIND']
set :port, ENV['PORT'] if ENV['PORT']

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
