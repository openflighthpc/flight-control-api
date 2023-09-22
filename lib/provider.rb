require "yaml"

require_relative 'config'

class Provider

  class << self
    def all
      @providers ||= [].tap do |a|
        Config.provider_paths.each do |p|
          Dir[File.join(p, '*')].each do |d|
            md = YAML.load_file(File.join(d, 'metadata.yaml'))
            a << Provider.new(md, d)
          end
        end
        a.sort_by(&:name)
      end
    end

    def [](search)
      provider = all.find{ |p| p.name == search }
      raise "Provider '#{search}' not found" unless provider
      provider
    end

    def each(&block)
      all.each(&block)
    end

    def exists?(search)
      !!all.find { |p| p.name == search }
    end
  end
  
  attr_reader :name, :dir
  
  def initialize(md, dir)
    @name = md['name']
    @dir = dir
  end
  
end
