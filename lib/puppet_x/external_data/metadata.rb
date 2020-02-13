module Puppet_X # rubocop:disable Style/ClassAndModuleCamelCase,Style/ClassAndModuleChildren
  module ExternalData # rubocop:disable Style/ClassAndModuleChildren
    # Metadata class
    #
    # This provides an object which acts like a hash, but stores metadata in the
    # cache. It is stored just like any other data, just with a metadata prefix
    #
    class Metadata < Hash
      def initialize(forager_name, cache)
        @cache   = cache
        @forager = forager_name
      end

      def [](k)
        @cache.get(@forager, "metadata-#{k}")
      end

      def []=(k, v)
        raise 'Metadata keys must be strings' unless k.is_a? String

        if v.nil?
          @cache.delete(@forager, "metadata-#{k}")
        else
          @cache.update(@forager, "metadata-#{k}", v)
        end
      end
    end
  end
end
