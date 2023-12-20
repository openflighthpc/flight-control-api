# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'open3'
require 'yaml'

require_relative 'config'

class SubprocessError < StandardError; end

class Provider
  class << self
    def all
      @all ||= [].tap do |a|
        Dir[File.join(Config.provider_path, '*')].each do |d|
          d = File.expand_path(d, Config.root)
          md = YAML.load_file(File.join(d, 'metadata.yaml'))
          a << Provider.new(md, d)
        end
        a.sort_by(&:id)
      end
    end

    def [](provider_id)
      provider = all.find { |p| p.id == provider_id }
      raise ProviderNotFoundError, provider_id if provider.nil?
      provider
    end

    def each(&)
      all.each(&)
    end

    def config
      @config ||= Config.new
    end
  end

  def list_instances(scope:, creds:)
    env = { 'SCOPE' => scope }
    JSON.parse(run_action('list_instances', creds:, env: env)).map do |instance|
      # result mapping
      if @action_result_map['list_instances']['state']['on'].include?(instance['state'])
        instance['state'] = 'on'
      elsif @action_result_map['list_instances']['state']['off'].include?(instance['state'])
        instance['state'] = 'off'
      else
        instance['state'] = 'unknown'
      end
      instance
    end
  end

  def model_details(models, creds:)
    env = { 'MODELS' => models.join(',') }
    JSON.parse(run_action('get_model_details', env: env, creds: creds))
  end

  def valid_credentials?(creds:)
    missing_credentials = @required_credentials - creds.keys
    raise MissingCredentialsError, missing_credentials unless missing_credentials.none?
    JSON.parse(run_action('authorise_credentials', creds:))['result']
  end

  def instance_usages(instance_ids, start_time, end_time, creds:)
    env = {
      'INSTANCE_IDS' => instance_ids.join(','),
      'START_TIME' => start_time,
      'END_TIME' => end_time
    }
    {
      'start_time' => start_time,
      'end_time' => end_time,
      'usages' => JSON.parse(run_action('get_instance_usages', creds:, env:))
    }
  end

  def start_instance(instance_id, creds:)
    env = {
      'INSTANCE_ID' => instance_id
    }

    run_action('start_instance', creds:, env:)
  end

  def stop_instance(instance_id, creds:)
    env = {
      'INSTANCE_ID' => instance_id
    }

    run_action('stop_instance', creds:, env:)
  end

  def list_models(creds:)
    JSON.parse(run_action('list_models', creds:))
  end

  def get_historic_instance_costs(*instance_ids, start_time, end_time, creds:)
    env = {
      'INSTANCE_IDS' => instance_ids.join(','),
      'START_TIME' => start_time,
      'END_TIME' => end_time
    }
    {
      'start_time' => start_time,
      'end_time' => end_time,
      'costs' => JSON.parse(run_action('get_instance_costs', creds:, env:))
    }
  end

  def prepare_command
    File.join(dir, 'prepare')
  end

  def prepared?
    statefile = File.join(dir, 'state.yaml')
    File.exist?(statefile) ? YAML.load_file(statefile)['prepared'] : false
  end

  def run_env
    FileUtils.mkdir_p(File.join(dir, 'run_env/')).first
  end

  def log_dir
    FileUtils.mkdir_p(File.join(dir, 'log/')).first
  end

  def run_action(action, creds:, env: {})
    prepare unless prepared?
    script = File.join(dir, 'actions', action)
    log_name = File.join(log_dir, "#{id}-#{File.basename(script, File.extname(script))}-#{Time.now.to_i}.log")

    raise ArgumentError, "The action '#{action}' is not available for '#{id}'" unless File.exist?(script)

    extra_vars = {
      'RUN_ENV' => run_env
    }
    env = creds.merge(env, extra_vars)
    env.transform_values!(&:to_s)

    stdout, stderr, status = Open3.capture3(
      env,
      script,
      chdir: run_env
    )

    File.open(log_name, 'a+') { |f| f.write stdout }

    unless status.success?
      File.open(log_name, 'a+') { |f| f.write stderr }
      raise SubprocessError, "Error running action. See #{log_name} for details."
    end

    stdout
  end

  attr_reader :id, :dir, :required_credentials

  def initialize(md, dir)
    @id = File.basename(dir)
    @dir = dir
    @required_credentials = md['required_credentials']
    @action_result_map = md['result_map']
  end

  def to_hash
    {
      id:,
      required_credentials:
    }
  end

  private

  def prepare
    raise "No prepare script available for '#{id}'" unless File.exist?(prepare_command)

    log_name = File.join(log_dir, "#{id}-prepare-#{Time.now.to_i}.log")
    Open3.popen2e(
      { 'RUN_ENV' => run_env },
      prepare_command,
      chdir: run_env
    ) do |_, stdout_stderr, wait_thr|
      Thread.new do
        stdout_stderr.each do |log|
          File.open(log_name, 'a+') { |f| f.write log }
        end
      end
      File.write(File.join(dir, 'state.yaml'), { 'prepared' => true }.to_yaml) if wait_thr.value.success?
    end
  end
end
