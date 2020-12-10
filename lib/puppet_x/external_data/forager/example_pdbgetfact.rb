require 'puppet_x/external_data/forager'
require 'puppet_x/external_data/multiplexer'

module Puppet_X::ExternalData # rubocop:disable Style/ClassAndModuleCamelCase
  # Example forager, not very useful other than testing
  class Forager::Example_Pdbgetfact < Puppet_X::ExternalData::Forager
    def initialize(opts)
      @data = nil
      # Since this is only used for testing it's good to be able to change the
      # way it works
      @type   = opts[:type] || :ondemand

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

      # Query PuppetDB for the nodes 'hostname' fact
      hostname = pdb_get_fact(certname, 'hostname')
      # Query PuppetDB for the 'release' leaf of the 'os' structured fact
      os_release = pdb_get_fact(certname, 'os.release')

      @data = {
        'certname'   => certname,
        'hostname'   => hostname,
        'os_release' => os_release,
      }
    end

    def name
      'example_pdbgetfact'
    end

  end
end

Puppet_X::ExternalData::Multiplexer.register_forager('example_pdbgetfact', Puppet_X::ExternalData::Forager::Example_Pdbgetfact)
