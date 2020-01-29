plan external_data::demo::provision (
  String $provisioner = 'vagrant',
) {
  case $provisioner {
    'vagrant': {
        run_task('provision::vagrant', 'localhost', {
          action          => 'provision',
          platform        => 'centos/7',
          inventory       => './',
          provider        => 'virtualbox',
          cpus            => 2,
          memory          => 4096,
          private_network => true,
        })
        run_task('provision::vagrant', 'localhost', {
          action          => 'provision',
          platform        => 'centos/7',
          inventory       => './',
          provider        => 'virtualbox',
          cpus            => 2,
          memory          => 4096,
          private_network => true,
        })
    }
    default: {
      # Do nothing
    }
  }

}
