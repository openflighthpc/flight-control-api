# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'yaml'

require_relative 'config'

class Provider
  class << self
    def all
      @providers ||= [].tap do |a|
        Dir[File.join(Config.fetch(:provider_path), '*')].each do |d|
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
    log_name = "#{log_dir}/#{id}-prepare-#{Time.now.to_i}.log"

    Open3.popen2e(
      prepare_command,
      chdir: run_env
    )  do |stdin, stdout_stderr, wait_thr|
      Thread.new do
        stdout_stderr.each do |l|
          File.open(log_name, "a+") { |f| f.write l}
        end
      end
      wait_thr.value
    end
    File.write(File.join(dir, 'state.yaml'), { 'prepared' => true }.to_yaml)
  end

  def prepare_command
    File.join(dir, 'prepare.sh')
  end

  def run_env
    FileUtils.mkdir_p(File.join(dir, 'run_env/')).first
  end

  def log_dir
    FileUtils.mkdir_p(File.join(dir, 'log/')).first
  end

  attr_reader :id, :dir

  def initialize(md, dir)
    @id = File.basename(dir)
    @dir = dir
  end

  def to_hash
    {
      id: @id
    }
  end
end
