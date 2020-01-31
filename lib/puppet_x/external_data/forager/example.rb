require 'puppet_x/external_data/forager'

module Puppet_X::ExternalData
  class Forager::Example < Puppet_X::ExternalData::Forager
    def initialize(opts)
      @data = nil
      super(opts)
    end

    def type
      :ondemand_cached
    end

    def name
      'example'
    end

    def get_data(certname)
      # If this has been called before then return that it hasn't changed
      return nil if @data

      @data = {
        'certname' => certname,
        'upcase'   => certname.upcase,
        'rot13'    => rot13(certname),
      }
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
