require 'sinatra'
require 'sinatra/custom_logger'
require 'logger'

require_relative './lib/control_api'

# Set up recognised environments
set :environments, %w[test production development]

configure do
  set :bind, ENV['BIND'] || Config.fetch(:bind)
  set :port, ENV['PORT'] || Config.fetch(:port)
end

# initialize logger
if Config.fetch(:log)
  ENV['LOG_PATH'] ||= Config.fetch(:log, :path)
  ENV['LOG_LEVEL'] ||= Config.fetch(:log, :path)
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
