plan external_data::demo::setup {
  $hosts     = get_targets('*')
  $primary   = $hosts[0]
  $secondary = $hosts[1]

  run_command('hostnamectl set-hostname master-primary.puppet.demo', $primary)
  run_command('hostnamectl set-hostname master-secondary.puppet.demo', $secondary)

  run_task('external_data::demo_install_pe', $primary)

  # Enable autosigning
  run_task('puppet_conf', $primary, {
    'action'  => 'set',
    'section' => 'master',
    'setting' => 'autosign',
    'value'   => 'true',
  })

  # Restart the puppetserver
  run_command('systemctl restart pe-puppetserver', $primary)

  run_plan('facts', $primary)
  $primary_ip = $primary.facts['virtual'] ? {
    'virtualbox' => $primary.facts['networking']['interfaces']['eth1']['ip'],
    default      => $primary.facts['ipaddress',]
  }

  run_command("echo ${primary_ip} ${primary.facts['fqdn']} >> /etc/hosts", $secondary)
  run_command("curl -k https://${primary.facts['fqdn']}:8140/packages/current/install.bash | bash", $secondary)
  run_command('until /opt/puppetlabs/bin/puppet agent -t; do sleep 1; done', $hosts)
  run_command('echo "`facter ipaddress` `facter fqdn`" >> /etc/hosts', $hosts)

  # Create host entries for secondary in primary
  run_plan('facts', $secondary)
  $secondary_ip = $secondary.facts['virtual'] ? {
    'virtualbox' => $secondary.facts['networking']['interfaces']['eth1']['ip'],
    default      => $secondary.facts['ipaddress',]
  }
  run_command("echo ${secondary_ip} ${secondary.facts['fqdn']} >> /etc/hosts", $primary)


  # Code deploy to initialise
  run_command('echo "puppetlabs" | puppet access login admin --lifetime 0', $primary)
  run_command('puppet code deploy --all --wait', $primary)

  # Provision the replica
  run_command('puppet infrastructure provision replica master-secondary.puppet.demo', $primary)
  run_command('puppet infrastructure enable replica master-secondary.puppet.demo --topology mono --yes', $primary)

  run_plan('external_data::demo::install', {
    'primary'   => $primary,
    'secondary' => $secondary,
  })

  return 'Done!'
}
