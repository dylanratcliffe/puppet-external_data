# Puppet External Data Foragers
#
# ## Forager Types
#
# ### `:ondemand`
#
# On Demand foragers execute each time the catalog is compiled for a particular
# host. They do no caching and should only be used when a very high performance
# backend is in place
#
# ### `:ondemand_cached`
#
# Similar to an `:ondemand` forager except that it is able to recieve an empty
# response from whatever this is querying and treat this as "The data has not
# changed" in which case the previous data for that node will be returned.
#
# These backends will also need to be able to recieve a response that means
# "There is no data here" in whihc case the cache for that node will need to be
# cleared and nothing returned to the puppetserver
#
# ### `:batch`
#
# Batch foragers will always return cached data on catalog compiles as they
# only do updates in batches.
#
require 'logger'
require 'puppet_x/external_data/metadata'
require 'puppet_pal'

module Puppet_X # rubocop:disable Style/ClassAndModuleCamelCase,Style/ClassAndModuleChildren
  module ExternalData # rubocop:disable Style/ClassAndModuleChildren
    # Base classe for foragers, all should inherit this
    class Forager
      attr_reader :cache
      attr_reader :logger
      attr_reader :metadata
      attr_reader :min_age

      def initialize(opts = {})
        # Perform validation
        validate_type

        raise ':cache option must be specified' unless opts[:cache]
        @cache = opts[:cache]

        # Default min_age to false
        @min_age = opts[:min_age] ? opts[:min_age].to_i : false # rubocop:disable Style/TernaryParentheses

        # Create logging config
        @logger       = opts[:logger] || Logger.new(STDERR)
        @metadata     = Puppet_X::ExternalData::Metadata.new(name, @cache)
      end

      # This method will be called each time a catalog is compiled. It should
      # return the data for a given node. Mostly it is responsible for calling
      # out to the appropriate methods to actually go and get the data.
      def data_for(certname)
        logger.info("#{name}: Finding data for #{certname}")

        # Only run this if we are using the feature, this will reduce load on
        # the metadata
        if min_age
          # Check the minimum age. This allows simpler foragers to retrieve
          # information for a node every x seconds, as needed. This will be
          # useful for APIs that don't have an "updated since" feature
          last_run = metadata["#{certname}-last_run"].to_i
          now      = Time.now.to_i
          if (now - last_run) < min_age
            logger.info("#{name}: #{certname} not older than min_age, using cache")
            return cache.get(name, certname)
          else
            metadata["#{certname}-last_run"] = now
          end
        end

        case type
        when :ondemand
          data = get_data(certname)

          # Only bother caching the data if there is a minimum age set,
          # otherwise the cache will never be used and there is no point
          if min_age != false
            logger.info("#{name}: #{certname} updated, persisting to cache")
            cache.update(name, certname, data)
          end

          return data
        when :ondemand_cached
          # Get the data
          data = get_data(certname)

          case data
          when nil
            logger.info("#{name}: #{certname} not updated, using cache")

            # This means that nothing has changed and we should use the cache
            return cache.get(name, certname)
          when {}
            logger.info("#{name}: #{certname} deleted, deleting cached data")

            # When an empty hash is returned it means that we need to delete the
            # cached data and return nothing
            cache.delete(name, certname)
            logger.info("#{name}: #{certname} deleted form cache")
            return nil
          else
            logger.info("#{name}: #{certname} updated, persisting to cache")
            cache.update(name, certname, data)
            logger.info("#{name}: #{certname} saved to cache")
            return data
          end
        when :batch
          # This should always get cached data
          cache.get(name, certname)
        end
      end

      def type
        raise "You must override the type method to return one of: #{valid_types}"
      end

      def name
        raise 'You must override the name method to return a name'
      end

      def get_data(_certname)
        raise 'You must override the get_data method to return a data for a node'
      end

      private

      def valid_types
        [
          :ondemand,
          :ondemand_cached,
          :batch,
        ]
      end

      def validate_type
        raise "type must be one of: #{valid_types}" unless valid_types.include? type
      end

      # Query PuppetDB for a fact on a given node.
      #
      # Params:
      #   certname - The certname of the node to query puppetdb for
      #
      #   factpath - The fact to query puppetdb for. A structured fact can be represented
      #     in dot notation (eg. os.release.major)
      #
      #   puppetdb[:confdir] - Location where puppetdb.conf resides.
      #     Also used to resolve certificate locations to connect to puppetdb.
      #     Defaults to /etc/puppetlabs/puppet
      #
      def pdb_get_fact(certname, factpath, puppetdb={confdir: '/etc/puppetlabs/puppet'})
        ast_query = ["from", "inventory", ["extract", "facts.#{factpath}",["=", "certname", "#{certname}"]]]

        # Puppet settings can only be initialized once
        unless Puppet.settings.global_defaults_initialized?
          Puppet.initialize_settings
          Puppet[:confdir] = puppetdb[:confdir]
        end

        begin
          # Use PAL to call puppetdb_query function 
          result = Puppet::Pal.in_tmp_environment("pal_env", modulepath: [], facts: {}) do |pal|
            pal.with_catalog_compiler do |compiler|
              compiler.call_function('puppetdb_query', ast_query)
            end
          end 

          # When successful result will be an array in the following form:
          #   [{"facts.#{factpath}" => value_of_fact}]
          # Otherwise it will be an empty array
          #
          # On success return the value_of_fact otherwise return nil
          result.empty? ? nil : result.first["facts.#{factpath}"]
        rescue Puppet::Error => e
          # Rescue any Puppet::Error's produced by PAL and log them as warnings.
          logger.warn("#{name}: #{e.message}")
          nil
        end
      end
     
    end
  end
end
