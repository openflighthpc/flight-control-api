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
      all.find { |p| p.id == provider_id }
    end

    def each(&)
      all.each(&)
    end

    def exists?(provider_id)
      !self[provider_id].nil?
    end

    def config
      @config ||= Config.new
    end
  end

  def list_instances(scope:, creds: {})
    JSON.parse(run_action('list_instances', creds:, scope:))
  end

  def model_details(model)
    env = { 'MODEL' => model }
    JSON.parse(run_action('model_details', env: env))
  end

  def valid_credentials?(creds:, scope:)
    run_action('authorise_credentials', creds:, scope:)
  end

  def instance_usages(instance_ids, start_time, end_time, scope:, creds: {})
    env = {
      'INSTANCE_IDS' => instance_ids.join(','),
      'START_TIME' => start_time,
      'END_TIME' => end_time
    }
    {
      'start_time' => start_time,
      'end_time' => end_time,
      'usages' => JSON.parse(run_action('instance_usages', creds:, scope:, env:))
    }
  end

  def start_instance(instance_id, scope:, creds: {})
    env = {
      'INSTANCE_ID' => instance_id
    }

    run_action('start_instance', creds:, scope:, env:)
  end

  def stop_instance(instance_id, scope:, creds: {})
    env = {
      'INSTANCE_ID' => instance_id
    }

    run_action('stop_instance', creds:, scope:, env:)
  end

  def list_models
    JSON.parse(run_action('list_models', scope: nil))
  end

  def get_historic_instance_costs(*instance_ids, start_time, end_time, creds:, scope:)
    env = {
      'INSTANCE_IDS' => instance_ids.join(','),
      'START_TIME' => start_time,
      'END_TIME' => end_time
    }
    {
      'start_time' => start_time,
      'end_time' => end_time,
      'costs' => JSON.parse(run_action('instance_costs', creds:, scope:, env:))
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

  def run_action(action, scope: nil, creds: {}, env: {})
    prepare unless prepared?
    script = File.join(dir, 'actions', action)
    log_name = File.join(log_dir, "#{id}-#{File.basename(script, File.extname(script))}-#{Time.now.to_i}.log")

    raise ArgumentError, "The action '#{action}' is not available for '#{id}'" unless File.exist?(script)

    extra_vars = {
      'RUN_ENV' => run_env,
      'SCOPE' => scope
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
      wait_thr.value
    end
    File.write(File.join(dir, 'state.yaml'), { 'prepared' => true }.to_yaml)
  end
end
