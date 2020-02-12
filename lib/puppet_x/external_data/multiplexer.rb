# External Data Multiplexer
#
# Example config
# ---
# cache:
#   name: file_sync
#   options:
#     location: /etc/foo
# foragers:
#   - name: example
#     options: {}
#
require 'yaml'

module Puppet_X
  module ExternalData
    class Multiplexer
      @@forager_classes = {} # rubocop:disable Style/ClassVars

      attr_reader :config
      attr_reader :cache
      attr_reader :foragers

      def initialize(config_file = nil)
        raise 'No config file specified' if config_file.nil?
        raise "Conifg file #{config_file} does not exist" unless File.file?(config_file)

        begin
          @config = YAML.safe_load(File.read(config_file))
        rescue StandardError => e
          raise "Error ancountered while parsing #{config_file}\n#{e}"
        end

        validate_config!
        @foragers = []

        # Load the specified cache
        cache_name    = config['cache']['name']
        cache_options = keys_to_sym(config['cache']['options'])

        require "puppet_x/external_data/cache/#{cache_name}"
        @cache = @@cache.new(cache_options)

        # Load all of the foragers
        config['foragers'].each do |forager|
          name = forager['name']
          # Load the ruby file. This should register itself
          require "puppet_x/external_data/forager/#{name}"

          # Pull the options out of the config
          opts = keys_to_sym(forager['options']) || {}
          opts[:cache] = cache

          # Pull out the forager class and initialize it
          raise "Forager #{name} not found" unless @@forager_classes.key? name

          @foragers << @@forager_classes[name].new(opts)
        end
      end

      def get(certname)
        require 'thread'

        threads = []
        @data   = {}
        foragers.each do |forager|
          threads << Thread.new do
            @data[forager.name] = forager.data_for(certname)
          end
        end
        threads.each(&:join)

        # Commit the data to the cache if it's required
        cache.commit

        @data
      end

      def self.register_cache(cache_class)
        @@cache = cache_class # rubocop:disable Style/ClassVars
      end

      def self.register_forager(name, forager_class)
        @@forager_classes[name] = forager_class
      end

      private

      def validate_config!
        raise 'cache must be specified' unless @config['cache']['name'].is_a? String

        cache_options = @config['cache']['options']
        raise 'cache options must be a hash, or absent' unless cache_options.nil? || cache_options.is_a?(Hash)
      end

      def keys_to_sym(hash)
        return nil if hash.nil? # Don't operate on nil

        hash.reduce({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
      end
    end
  end
end