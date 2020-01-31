require 'puppet_x/external_data/forager'
require 'puppet_x/external_data/multiplexer'

module Puppet_X::ExternalData
  class Forager::Example < Puppet_X::ExternalData::Forager
    def initialize(opts)
      @data = nil
      @colour = opts[:colour] || 'not specified'
      super(opts)
    end

    def type
      :ondemand_cached
    end

    def get_data(certname)
      # If this has been called before then return that it hasn't changed
      return nil if @data

      @data = {
        'certname' => certname,
        'upcase'   => certname.upcase,
        'colour'   => @colour,
        'rot13'    => rot13(certname),
      }
    end

    def name
      'example'
    end

    private

    def rot13(string)
      string.downcase.tr(
        'abcdefghijklmnopqrstuvwxyz',
        'nopqrstuvwxyzabcdefghijklm',
      )
    end
  end
end

Puppet_X::ExternalData::Multiplexer.register_forager('example', Puppet_X::ExternalData::Forager::Example)
