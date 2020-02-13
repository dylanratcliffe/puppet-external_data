require 'puppet_x/external_data/forager'
require 'puppet_x/external_data/multiplexer'

module Puppet_X::ExternalData # rubocop:disable Style/ClassAndModuleCamelCase
  # Example forager, not very useful other than testing
  class Forager::Example < Puppet_X::ExternalData::Forager
    def initialize(opts)
      @data = nil
      @colour = opts[:colour] || 'not specified'
      # Since this is only used for testing it's good to be able to change the
      # way it works
      @type   = opts[:type] || :ondemand_cached

      raise 'colour must be a string' unless @colour.is_a? String

      super(opts)
    end

    def type
      # Usually this swould just be static i.e.
      # :ondemand
      @type.to_sym
    end

    def get_data(certname)
      # If this has been called before then return that it hasn't changed
      if type == :ondemand_cached
        return nil if metadata["#{certname}-updated"]
        metadata["#{certname}-updated"] = true
      end

      raise 'certname must not be blank' if certname.empty?

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
