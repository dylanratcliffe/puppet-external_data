# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   puppet_enterprise::file_sync_directory { 'namevar': }
define external_data::file_sync_repo (
  String  $live_dir,
  Puppet_enterprise::Replication_mode $replication_mode,
  String  $staging_dir           = $live_dir,
  String  $ensure                = 'present',
  Boolean $auto_commit           = false,
  Boolean $honor_gitignore       = true,
  String  $file_sync_config_file = '/etc/puppetlabs/puppetserver/conf.d/file-sync.conf',
) {
  $is_source  = $replication_mode == 'source'
  $is_replica = $replication_mode == 'replica'

  Pe_hocon_setting {
    path => $file_sync_config_file,
  }

  $file_sync_repo_setting = "file-sync.repos.${name}"
  $present_if_is_source   = $is_source ? {
    true  => 'present',
    false => 'absent',
  }

  if $ensure == 'absent' {
    pe_hocon_setting { $file_sync_repo_setting:
      ensure  => absent,
      setting => $file_sync_repo_setting,
    }
  }

  pe_hocon_setting { "${file_sync_repo_setting}.staging-dir":
    ensure  => $present_if_is_source,
    setting => "${file_sync_repo_setting}.staging-dir",
    value   => $staging_dir,
  }

  pe_hocon_setting { "${file_sync_repo_setting}.client-active":
    ensure  => $present_if_is_source,
    setting => "${file_sync_repo_setting}.client-active",
    value   => false,
  }

  pe_hocon_setting { "${file_sync_repo_setting}.auto-commit":
    ensure  => $present_if_is_source,
    setting => "${file_sync_repo_setting}.auto-commit",
    value   => $auto_commit,
  }

  pe_hocon_setting { "${file_sync_repo_setting}.honor-gitignore":
    ensure  => $present_if_is_source,
    setting => "${file_sync_repo_setting}.honor-gitignore",
    value   => $honor_gitignore,
  }

  if $is_replica {
    file { $live_dir:
      ensure => 'directory',
      mode   => '0700',
    }

    pe_hocon_setting { "${file_sync_repo_setting}.live-dir":
      ensure  => present,
      setting => "${file_sync_repo_setting}.live-dir",
      value   => $live_dir,
      require => File[$live_dir]
    }
  } else {
    pe_hocon_setting { "${file_sync_repo_setting}.live-dir":
      ensure  => absent,
      setting => "${file_sync_repo_setting}.live-dir",
    }
  }
}
