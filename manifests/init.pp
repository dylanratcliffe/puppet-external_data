class external_data (
  String $data_live_dir = '/opt/puppetlabs/puppetserver/external_data',
  String $data_staging_dir = '/opt/puppetlabs/puppetserver/external_data_staging',
  Puppet_enterprise::Replication_mode $replication_mode = 'source',
) {

  # Ensure that directories exist
  file { [$data_live_dir, $data_staging_dir]:
    ensure => 'directory',
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0750',
  }
}
