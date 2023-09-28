require 'yaml'

class Config

  def self.setup_singleton(...)
    @singleton = new(...)
  end

  def self.fetch(key)
    return unless @singleton
    @singleton.send(key)
  end

  attr_reader :provider_path

  def initialize(provider_path:)
    @provider_path = provider_path || File.join(__dir__, '../../etc/providers')
  end
end
