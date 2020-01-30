plan external_data::demo::install (
  String     $module_version = '0.1.0',
  TargetSpec $primary        = get_targets('*')[0],
  TargetSpec $secondary      = get_targets('*')[1],
) {
  run_command('bundle exec pdk build module --force', 'localhost')
  upload_file(
    "external_data/../pkg/dylanratcliffe-external_data-${module_version}.tar.gz",
    "/tmp/dylanratcliffe-external_data-${module_version}.tar.gz",
    $primary
  )
  run_command("puppet module install /tmp/dylanratcliffe-external_data-${module_version}.tar.gz --target-dir /opt/puppetlabs/puppet/modules", $primary)

  apply_prep([$primary, $secondary])

  apply($primary, _noop => false, _run_as => root) {
    class { 'external_data':
      replication_mode => 'source'
    }
  }

  apply($secondary, _noop => false, _run_as => root) {
    class { 'external_data':
      replication_mode => 'replica'
    }
  }
}
