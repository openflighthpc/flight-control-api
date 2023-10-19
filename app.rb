# frozen_string_literal: true
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

LOGGER = Logger.new(ENV['LOG_PATH'] || $stdout)

log_levels = {
  'debug' => Logger::DEBUG,
  'info' => Logger::INFO,
  'warn' => Logger::WARN,
  'error' => Logger::ERROR,
  'fatal' => Logger::FATAL
}

raise 'Invalid log level' if ENV['LOG_LEVEL'] && !log_levels.key?(ENV['LOG_LEVEL'])

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

  # Endpoints specific to a provider
  namespace '/:id' do
    helpers do
      def id_param
        params['id']
      end

      def provider
        Provider[id_param]
      end

      def request_body
        request.body.rewind
        @request_body ||= request.body.read.tap do |body|
          halt 401, 'Malformed JSON body' unless valid_json?(body)
        end
      end

      def credentials
        JSON.parse(request_body)['credentials'] || {}
      end

      def project
        @project ||= Project.new(params['id'], credentials)
      end

      def validate_credentials
        puts project.required_credentials?
        if !project.required_credentials?
          body "Missing credentials: #{project.missing_credentials.join(', ')}"
          halt 401
        elsif !Project.new(params['id'], credentials).valid_credentials?
          body 'Invalid credentials'
          halt 401
        end
      end
    end

    before do
      halt 404, 'Provider not found' unless provider
    end

    # Show provider attributes
    get do
      return provider.to_hash.to_json
    end

    post '/validate-credentials' do
      validate_credentials
    end
  end
end
