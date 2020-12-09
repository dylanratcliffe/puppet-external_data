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
        ast_query = ["from", "inventory", ["extract", "facts.#{factpath}",["=", "certname", "#{certname}"]]]

        Puppet.initialize_settings unless Puppet.settings.global_defaults_initialized?

        Puppet[:confdir] = puppetdb[:confdir]

        result = Puppet::Pal.in_tmp_environment("pal_env", modulepath: [], facts: {}) do |pal|
          pal.with_catalog_compiler do |compiler|
            compiler.call_function('puppetdb_query', ast_query)
          end
        end 

        result.first["facts.#{factpath}"]
      end

    end
  end
end
