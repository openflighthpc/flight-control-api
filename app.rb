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

helpers do
  def valid_json?(str)
    JSON.parse(str)
  rescue JSON::ParserError
    false
  end
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
  post '/:id/validate-credentials' do
    body = request.body.read
    return [401, 'Malformed JSON body'] unless valid_json?(body)

    credentials = JSON.parse(body)['credentials']
    project = Project.new(params['id'], credentials)

    if !project.required_credentials?
      status 401
      body "Missing credentials: #{project.missing_credentials.join(', ')}"
    elsif Project.new(params['id'], credentials).valid_credentials?
      'OK'
    else
      status 401
      body 'Invalid credentials'
    end
  end
end
