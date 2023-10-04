require 'yaml'
require 'sinatra/base'

class Config
  #==============================================================================
  # Some of the following logic is adapted from Sinatra::SinatraContrib::ConfigFile.
  # https://github.com/sinatra/sinatra/blob/main/sinatra-contrib/lib/sinatra/config_file.rb
  #
  # It is used under the following license:
  #
  # The MIT License (MIT)
  #
  # Copyright (c) 2007, 2008, 2009 Blake Mizerany
  # Copyright (c) 2010-2017 Konstantin Haase
  # Copyright (c) 2015-2017 Zachary Scott
  #
  # Permission is hereby granted, free of charge, to any person
  # obtaining a copy of this software and associated documentation
  # files (the "Software"), to deal in the Software without
  # restriction, including without limitation the rights to use,
  # copy, modify, merge, publish, distribute, sublicense, and/or sell
  # copies of the Software, and to permit persons to whom the
  # Software is furnished to do so, subject to the following
  # conditions:
  #
  # The above copyright notice and this permission notice shall be
  # included in all copies or substantial portions of the Software.
  #
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  # OTHER DEALINGS IN THE SOFTWARE.
  #==============================================================================

  class << self
    def fetch(*keys)
      config.dig(*keys.map(&:to_s))
    end

    def config
      @config ||= read_from_file(File.join(Config.root, 'etc/config.yml'))
    end

    def root
      Sinatra::Application.root
    end

    def environment
      Sinatra::Application.environment
    end

    def environments
      Sinatra::Application.environments
    end

    def read_from_file(file)
      document = ERB.new(File.read(file)).result
      yaml = YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(document) : YAML.load(document)

      config_for_env(yaml)
    end

    def config_for_env(hash)
      return from_environment_key(hash) if environment_keys?(hash)

      hash.each_with_object(Sinatra::IndifferentHash[]) do |(k, v), acc|
        acc.merge!(k => v)

        if environment_keys?(v)
          acc.merge!(k => v[environment.to_s]) if v.key?(environment.to_s)
        else
          acc.merge!(k => v)
        end
      end
    end

    def from_environment_key(hash)
      hash[environment.to_s] || hash[environment.to_sym] || {}
    end

    def environment_keys?(hash)
      hash.is_a?(Hash) && hash.any? { |k, _| environments.include?(k.to_s) }
    end
  end
end
