require 'puppet_x/external_data/cache'

# Very simple example cache for testing
module Puppet_X::ExternalData
  class Cache::Example
    def initialize
      @storage = {}
    end

    def get(certname)
      @storage[certname]
    end

    def delete(certname)
      @storage.delete(certname)
    end

    def update(certname, data)
      @storage[certname] = data
    end
  end
end