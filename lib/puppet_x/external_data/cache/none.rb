require 'puppet_x/external_data/cache'
require 'puppet_x/external_data/multiplexer'

# Very simple example cache. It caches data in memory which is only useful for
# testing as normally each request will be made in a new process.
module Puppet_X::ExternalData # rubocop:disable Style/ClassAndModuleCamelCase
  # This cache does no caching
  class Cache::None < Puppet_X::ExternalData::Cache
    def self.name
      'none'
    end

    def initialize(_opts = {})
      @storage = {}
    end

    def _get(forager, certname)
      ensure_forager(forager)

      @storage[forager][certname]
    end

    def _delete(forager, certname)
      ensure_forager(forager)

      @storage[forager].delete(certname)
    end

    def _update(forager, certname, data)
      ensure_forager(forager)

      @storage[forager][certname] = data
    end

    private

    def ensure_forager(forager)
      @storage[forager] = {} if @storage[forager].nil?
    end
  end
end

# This registers the cache class so that it can be users
Puppet_X::ExternalData::Multiplexer.register_cache(Puppet_X::ExternalData::Cache::None)
