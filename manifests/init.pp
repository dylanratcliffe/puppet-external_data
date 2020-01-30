class external_data (
  String $data_live_location    = '/etc/puppetlabs/puppetserver/external_data',
  String $data_staging_location = '/etc/puppetlabs/puppetserver/external_data_staging',
  String $replication_mode      = 'source',
) {
  # Ensure that file sync is working
  external_data::file_sync_repo { 'external-data':
    replication_mode => $replication_mode,
    live_location    => $data_live_location,
    staging_location => $data_staging_location,
  }
}
