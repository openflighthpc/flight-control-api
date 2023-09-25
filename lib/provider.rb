# frozen_string_literal: true

require 'yaml'

require_relative 'config'

class Provider
  class << self
    def all
      @providers ||= [].tap do |a|
        Dir[File.join(Config.provider_path, '*')].each do |d|
          md = YAML.load_file(File.join(d, 'metadata.yaml'))
          a << Provider.new(md, d)
        end
        a.sort_by(&:name)
      end
    end

    def [](search)
      all.find { |p| p.name == search }
    end

    def each(&block)
      all.each(&block)
    end

    def exists?(search)
      !all.find { |p| p.name == search }.nil?
    end
  end

  attr_reader :name, :dir

  def initialize(md, dir)
    @name = md['name']
    @dir = dir
  end
end
