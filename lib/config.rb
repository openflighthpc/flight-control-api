require 'yaml'
require 'tty-config'

class Config

  def self.root_dir
    @@root ||= File.expand_path(File.join(__dir__, '..'))
  end

  def self.global_config_path
    @@global_config_path ||= File.join(self.root_dir, 'etc', 'config.yml')
  end

  def self.global_config
    @@global_config ||= File.file?(self.global_config_path) ? YAML.safe_load(File.read(self.global_config_path)) : {}
  end
  
  def self.provider_paths
    @@provider_paths ||= self.global_config['provider_paths'] || []
  end

end
