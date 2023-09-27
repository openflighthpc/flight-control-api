# frozen_string_literal: true

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

    def [](search)
      all.find { |p| p.id == search }
    end

    def each(&block)
      all.each(&block)
    end

    def exists?(search)
      !all.find { |p| p.id == search }.nil?
    end
    
    def config
      @config ||= Config.new
    end
  end

  attr_reader :id, :dir

  def initialize(md, dir)
    @id = File.basename(dir)
    @dir = dir
  end
end
