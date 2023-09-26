require 'yaml'

class Config

  attr_reader :provider_path

  def initialize
    config_path = File.expand_path(File.join(__dir__, '..', 'etc', 'config.yml'))
    config = File.file?(config_path) ? YAML.safe_load(File.read(config_path)) : {}
    @provider_path = config['provider_path']
  end

end
