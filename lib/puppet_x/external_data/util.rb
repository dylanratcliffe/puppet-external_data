require 'puppet_pal'

module Puppet_X # rubocop:disable Style/ClassAndModuleCamelCase,Style/ClassAndModuleChildren
  module ExternalData # rubocop:disable Style/ClassAndModuleChildren
    class Util

      # Query PuppetDB for a fact on a given node.
      #
      # Params:
      #   certname - The certname of the node to query puppetdb for
      #
      #   factpath - The fact to query puppetdb for. A structured fact can be represented
      #     in dot notation (eg. os.release.major)
      #
      #   puppetdb[:confdir] - Location where puppetdb.conf resides.
      #     Also used to resolve certificate locations to connect to puppetdb.
      #     Defaults to /etc/puppetlabs/puppet
      #
      def self.pdb_get_fact(certname, factpath, puppetdb={confdir: '/etc/puppetlabs/puppet'})
        if factpath.include?('.')
          ast_query = ["from", "fact_contents", ["and", ["=", "certname", "#{certname}"], ["=", "path", factpath.split('.')]]]
        else
          ast_query = ["from", "facts", ["and", ["=", "certname", "#{certname}"], ["=", "name", factpath]]]
        end

        Puppet.initialize_settings
        Puppet[:confdir] = puppetdb[:confdir]

        result = Puppet::Pal.in_tmp_environment('pal_env', modulepath: [], facts: {}) do |pal|
          pal.with_catalog_compiler do |compiler|
            compiler.call_function('puppetdb_query', ast_query)
          end
        end 
        result.first['value']
      end

    end
  end
end
