require 'puppet_x/external_data/cache'
require 'puppet_x/external_data/multiplexer'
require 'json'

# Disk cache
module Puppet_X::ExternalData
  class Cache::Disk < Puppet_X::ExternalData::Cache
    attr_reader :path

    def self.name
      'disk'
    end

    def initialize(opts)
      @path = opts[:path]
    end

    def _get(forager, certname)
      ensure_forager(forager)

      JSON.parse(File.read(certname_path(forager, certname)))
    end

    def _delete(forager, certname)
      ensure_forager(forager)

      File.delete(certname_path(forager, certname))
    end

    def _update(forager, certname, data)
      ensure_forager(forager)

      File.write(certname_path(forager, certname), data.to_json)
    end

    private

    def ensure_forager(forager)
      Dir.mkdir(forager_path(forager)) unless File.directory? forager_path(forager)
    end

    def forager_path(forager)
      File.join(path, forager)
    end

    def certname_path(forager, certname)
      File.join(forager_path(forager), "#{certname}.json")
    end
  end
end

# This registers the cache class so that it can be users
Puppet_X::ExternalData::Multiplexer.register_cache(Puppet_X::ExternalData::Cache::Disk)
