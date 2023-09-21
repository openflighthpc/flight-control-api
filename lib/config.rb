require 'yaml'

class Config

  def self.root_dir
    @@root ||= File.expand_path(File.join(__dir__, '..'))
  end

  def self.global_config
    @@global_config ||= YAML.safe_load(File.read(File.join(self.root_dir, 'etc', 'config.yml'))) || {}
  end

  def self.env
    # should never return nil
    @@env ||= self.global_config['env'] || ENV['APP_ENV'] || 'development'
  end

  def self.env_path
    @@env_path ||= self.global_config[self.env + '_config_path'] || File.join(self.root_dir, 'etc', self.env + '.yml')
  end

  def self.env_config
    @@env_config ||= YAML.safe_load(File.read(self.env_path)) || {}
  end

  def self.port
    @@port ||= self.env_config['port'] || self.global_config['port']
  end

end