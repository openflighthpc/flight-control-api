# frozen_string_literal: true

require 'sinatra'
require 'sinatra/custom_logger'
require 'sinatra/namespace'
require 'logger'

require_relative 'lib/control_api'

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

      def scope_param
        params['scope']
      end

      def provider
        Provider[id_param]
      end

      def request_body
        request.body.rewind
        body = request.body.read

        # It looks like Sinatra attempts to parse the request body
        # automatically if the content type is `application/json`.
        if body.is_a?(String)
          halt 400, 'Malformed JSON body' if body.is_a?(String) && !valid_json?(body)
          @request_body ||= JSON.parse(body)
        elsif body.is_a?(Hash)
          @request_body ||= body
        else
          halt 400, 'Malformed request body'
        end
      end

      def credentials
        if request.env['HTTP_PROJECT_CREDENTIALS'] && valid_json?(request.env['HTTP_PROJECT_CREDENTIALS'])
          JSON.parse(request.env['HTTP_PROJECT_CREDENTIALS'])
        else
          {}
        end
      end

      def project
        @project ||= Project.new(id_param, credentials, scope_param)
      end

      def validate_credentials
        if !project.required_credentials?
          body "Missing credentials: #{project.missing_credentials.join(', ')}"
          halt 401
        elsif !Project.new(id_param, credentials).valid_credentials?
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

    get '/instance-details' do
      model = params['model']
      provider.instance_details(model).to_json
    rescue SubprocessError
      halt 500, 'Error fetching instance details'
    end

    get '/list-instances' do
      validate_credentials

      project.list_instances.to_json
    rescue SubprocessError
      halt 500, 'Error fetching instance list'
    end

    post '/start-instance' do
      validate_credentials

      instance_id = request_body['instance_id']

      halt 404, "Instance #{instance_id} not found" unless project.list_instances.any? { |i| i['name'] == instance_id }

      project.start_instance(instance_id)

      "Started #{instance_id}"
    rescue SubprocessError
      halt 500, "Error starting #{instance_id}"
    end

    post '/stop-instance' do
      validate_credentials

      instance_id = request_body['instance_id']

      halt 404, "Instance #{instance_id} not found" unless project.list_instances.any? { |i| i['name'] == instance_id }

      project.stop_instance(instance_id)

      "Stopped #{instance_id}"
    rescue SubprocessError
      halt 500, "Error stopping #{instance_id}"
    end
  end
end
