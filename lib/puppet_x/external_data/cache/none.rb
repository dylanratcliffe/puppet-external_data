require 'puppet_x/external_data/cache'
require 'puppet_x/external_data/multiplexer'

# Very simple example cache. It caches data in memory which is only useful for
# testing as normally each request will be made in a new process.
module Puppet_X::ExternalData
  class Cache::None < Puppet_X::ExternalData::Cache
    def self.name
      'none'
    end

    def initialize(_opts = {})
      @storage = {}
    end

    def _get(certname)
      @storage[certname]
    end

    def _delete(certname)
      @storage.delete(certname)
    end

    def _update(certname, data)
      @storage[certname] = data
    end
  end
end

# This registers the cache class so that it can be users
Puppet_X::ExternalData::Multiplexer.register_cache(Puppet_X::ExternalData::Cache::None)
