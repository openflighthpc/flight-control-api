require 'sinatra'
require 'sinatra/custom_logger'
require 'sinatra/namespace'
require 'logger'

require_relative './lib/control_api'

# Set up recognised environments
set :environments, %w[test production development]
set :root, File.dirname(__FILE__)

configure do
  def bind
    ENV['BIND'] || Config.fetch(:bind)
  end

  def port
    ENV['PORT'] || Config.fetch(:port)
  end

  set :bind, bind if bind
  set :port, port if port
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

  # verify credentials
  post '/:id/validate_credentials' do
    begin
      return 401 unless Project.new(params['id'], params['credentials']).valid_credentials?
    rescue
      return 401
    end
    'OK'
  end
end
