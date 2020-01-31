module Puppet_X
  module ExternalData
    class Cache
      def self.name
        raise 'Cache must define self.name'
      end
    end
  end
end