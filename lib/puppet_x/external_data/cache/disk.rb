require 'puppet_x/external_data/cache'
require 'puppet_x/external_data/multiplexer'
require 'fileutils'
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

      begin
        JSON.parse(File.read(certname_path(forager, certname)))
      rescue StandardError
        # If something went wrong then we don't have a cache
        return nil
      end
    end

    def _delete(forager, certname)
      ensure_forager(forager)

      file = certname_path(forager, certname)
      File.delete(file) if File.file? file
    end

    def _update(forager, certname, data)
      ensure_forager(forager)

      File.write(certname_path(forager, certname), data.to_json)
    end

    private

    def ensure_forager(forager)
      FileUtils.mkdir_p(forager_path(forager)) unless File.directory? forager_path(forager)
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
