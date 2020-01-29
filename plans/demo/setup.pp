plan external_data::demo::setup {
  $hosts = get_targets('*')

  run_task('external_data::demo_install_pe', $hosts)


}
