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

  def valid_timestamp?(timestamp)
    Time.at(timestamp)
  rescue TypeError
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

      def time_param(time)
        t = params[time]
        halt 400, "Missing #{time}" unless t
        halt 400, "Malformed #{time}" unless t.match?(/\A\d+\z/)
        halt 400, "#{time} must be earlier than the current time" if t.to_i > Time.now.to_i
        t.to_i
      end

      def provider
        Provider[id_param]
      rescue ProviderNotFoundError => e
        halt 404, e.message
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
        creds = request.env['HTTP_PROJECT_CREDENTIALS']
        return JSON.parse(creds) if creds && valid_json?(creds)
        {}
      end

      def instances
        provider.list_instances(scope: scope_param, creds: credentials)
      end

      def validate_credentials
        halt 401, 'Invalid credentials' unless provider.valid_credentials?(creds: credentials)
      rescue MissingCredentialsError => e
        halt 401, e.message
      rescue SubprocessError
        halt 500, 'Error validating credentials'
      end
    end

    # Show provider attributes
    get do
      return provider.to_hash.to_json
    end

    get '/instance-costs' do
      validate_credentials

      start_time = time_param('start_time')
      end_time = time_param('end_time')
      halt 400, 'Start time must be earlier than end time' if start_time > end_time

      halt 400, 'Missing instance id' unless params['instance_ids']
      instance_ids = params['instance_ids'].split(',').reject(&:empty?).uniq
      all_instances = instances.map { |i| i['instance_id'] }
      non_existent_instances = instance_ids.reject { |id| all_instances.include?(id) }
      halt 404, "Instance(s) #{non_existent_instances.join(',')} not found" if non_existent_instances.any?

      provider.get_historic_instance_costs(*instance_ids, start_time, end_time, creds: credentials).to_json
    rescue SubprocessError
      halt 500, "Error fetching instance costs for instances #{instance_ids.join(',')}"
    end

    post '/validate-credentials' do
      validate_credentials
    end

    get '/models' do
      validate_credentials
      provider.list_models(creds: credentials).to_json
    rescue SubprocessError
      halt 500, 'Error fetching list of models'
    end

    get '/model-details' do
      validate_credentials
      halt 400, 'Missing model' unless params['models']
      models = params['models'].split(',').reject(&:empty?).uniq
      all_models = provider.list_models(creds: credentials)
      non_existent_models = models.reject { |model| all_models.include?(model) }
      halt 404, "Model(s) #{non_existent_models.join(',')} does not exist" if non_existent_models.any?
      provider.model_details(models, creds: credentials).to_json
    rescue SubprocessError
      halt 500, 'Error fetching model details'
    end

    get '/instances' do
      validate_credentials

      instances.to_json
    rescue SubprocessError
      halt 500, 'Error fetching instance list'
    end

    get '/instance-usages' do
      validate_credentials

      start_time = time_param('start_time')
      end_time = time_param('end_time')
      halt 400, 'Start time must be earlier than end time' if start_time > end_time

      halt 400, 'Missing instance id' unless params['instance_ids']
      instance_ids = params['instance_ids'].split(',').reject(&:empty?).uniq
      all_instances = instances.map { |i| i['instance_id'] }
      non_existent_instances = instance_ids.reject { |id| all_instances.include?(id) }
      halt 404, "Instance(s) #{non_existent_instances.join(',')} not found" if non_existent_instances.any?

      provider.instance_usages(instance_ids, start_time, end_time, creds: credentials).to_json
    rescue SubprocessError
      halt 500, "Error fetching the usage of instances  #{instance_ids.join(',')}"
    end

    post '/start-instance' do
      validate_credentials

      instance_id = request_body['instance_id']
      halt 400, 'Missing instance id' unless instance_id
      halt 404, "Instance #{instance_id} not found" unless instances.any? { |i| i['instance_id'] == instance_id }

      provider.start_instance(instance_id, creds: credentials)

      "Started #{instance_id}"
    rescue SubprocessError
      halt 500, "Error starting #{instance_id}"
    end

    post '/stop-instance' do
      validate_credentials

      instance_id = request_body['instance_id']
      halt 400, 'Missing instance id' unless instance_id
      halt 404, "Instance #{instance_id} not found" unless instances.any? { |i| i['instance_id'] == instance_id }

      provider.stop_instance(instance_id, creds: credentials)

      "Stopped #{instance_id}"
    rescue SubprocessError
      halt 500, "Error stopping #{instance_id}"
    end
  end
end
