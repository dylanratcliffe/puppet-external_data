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
module Puppet_X
  module ExternalData
    class Forager
      attr_reader :cache

      def initialize(opts = {})
        # Perform validation
        validate_type

        raise ':cache option must be specified' unless opts[:cache]
        @cache = opts[:cache]
      end

      # This method will be called each time a catalog is compiled. It should
      # return the data for a given node. Mostly it is responsible for calling
      # out to the appropriate methods to actually go and get the data.
      def data_for(certname)
        case type
        when :ondemand
          get_data(certname)
        when :ondemand_cached
          # Get the data
          data = get_data(certname)

          case data
          when nil
            # This means that nothing has changed and we should use the cache
            return cache.get(certname)
          when {}
            # When an empty hash is returned it means that we need to delete the
            # cached data and return nothing
            # TODO: Delete from cache
            cache.delete(certname)
            return nil
          else
            cache.update(certname, data)
            return data
          end
        when :batch
          # This should always get cached data
          cache.get(certname)
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
    end
  end
end
