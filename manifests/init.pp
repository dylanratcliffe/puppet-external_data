# @summary A short summary of the purpose of this class
#
# Configures the external_data multiplexer
#
# @example
#   class { 'external_data':
#     config => {
#       'cache'    => {
#         'name' => 'none',
#       },
#       'foragers' => [
#         {
#           'name'    => 'example',
#           'options' => {
#             'colour' => 'red',
#           }
#         }
#       ]
#     }
#   }
#
# @param config The full config as a hash
# @param puppetserver_user The user that should own the config file
# @param confdir Where the config file should be created
# @param script_location Where the script should be stored
class external_data (
  Hash   $config,
  String $puppetserver_user = 'pe-puppet',
  String $confdir           = $settings::confdir,
  String $script_location   = '/opt/puppetlabs/bin/external_data.rb',
) {
  file { 'trusted_external_command script':
    ensure  => 'file',
    path    => $script_location,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('external_data/external_data.rb.epp', {
      'config_file' => "${confdir}/external_data.yaml",
    })
  }

  file { 'trusted_external_command config':
    ensure  => 'file',
    path    => "${confdir}/external_data.yaml",
    owner   => $puppetserver_user,
    group   => $puppetserver_user,
    mode    => '0600',
    content => Sensitive($config.to_yaml),
  }

  ini_setting { 'trusted_external_command':
    ensure  => present,
    path    => "${confdir}/puppet.conf",
    section => 'master',
    setting => 'trusted_external_command',
    value   => $script_location,
  }
}
