class external_data::puppetserver_reload {
  exec { 'reload pe-puppetserver for external_data':
    command     => 'systemctl reload pe-puppetserver',
    path        => $facts['path'],
    refreshonly => true,
  }
}
