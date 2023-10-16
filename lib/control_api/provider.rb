# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'open3'
require 'yaml'

require_relative 'config'

class Provider
  class << self
    def all
      @providers ||= [].tap do |a|
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

    def each(&block)
      all.each(&block)
    end

    def exists?(provider_id)
      !self[provider_id].nil?
    end

    def config
      @config ||= Config.new
    end
  end

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

  def list_instances(creds: {}, scope:)
    JSON.parse(run_action('list_instances.sh', creds: creds, scope: scope))
  end

  def valid_credentials?(creds:, scope:)
    begin
      run_action('authorise_credentials.sh', creds: creds, scope: scope)
      return true
    rescue RuntimeError => e
    end
    false
  end

  def start_instance(instance_id, scope:, creds: {})
    env = {
      'INSTANCE_ID' => instance_id
    }

    run_action('start_instance.sh', creds:, scope:, env:)
  end

  def stop_instance(instance_id, scope:, creds: {})
    env = {
      'INSTANCE_ID' => instance_id
    }

    run_action('stop_instance.sh', creds:, scope:, env:)
  end

  def list_types
    JSON.parse(run_action('list_types.sh', scope: nil))
  end

  def prepare_command
    File.join(dir, 'prepare.sh')
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

  def run_action(action, scope:, creds: {}, env: {})
    script = File.join(dir, 'actions', action)

    raise ArgumentError, "The action '#{action}' is not available for '#{id}'" unless File.exist?(script)

    stdout, stderr, status = Open3.capture3(
      {
        'RUN_ENV' => run_env,
        'SCOPE' => scope,
      }.merge(creds, env),
      script,
      chdir: run_env
    )

    unless status.success?
      log_name = File.join(log_dir,"#{id}-#{File.basename(script, File.extname(script))}-#{Time.now.to_i}.log")
      File.open(log_name, 'a+') { |f| f.write stderr }
      raise "Error running action. See #{log_name} for details."
    end

    return stdout
  end

  attr_reader :id, :dir, :required_credentials

  def initialize(md, dir)
    @id = File.basename(dir)
    @dir = dir
    @required_credentials = md['required_credentials']
  end

  def to_hash
    {
      id: @id
    }
  end
end
