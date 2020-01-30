# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   puppet_enterprise::file_sync_directory { 'namevar': }
define external_data::file_sync_repo (
  String  $live_location,
  Puppet_enterprise::Replication_mode $replication_mode,
  Optional[String] $staging_location = undef,
  String  $ensure                    = 'present',
  Boolean $auto_commit               = false,
  Boolean $honor_gitignore           = true,
  Boolean $client_active             = true,
  String  $file_sync_config_file     = '/etc/puppetlabs/puppetserver/conf.d/file-sync.conf',
) {
  $is_source  = $replication_mode == 'source'
  $is_replica = $replication_mode == 'replica'

  Pe_hocon_setting {
    path   => $file_sync_config_file,
    # notify => Service['pe-puppetserver'],
  }

  File {
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0750',
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

  # If a staging dir has been provided, then the source needs both the staging
  # and live dirs set. Regardless the replica only ever has a live-dir
  case $replication_mode {
    'source': {
      if $staging_location {
        $source_staging_dir = $staging_location

        # If we are using a staging dir then the live dir is a separate location
        file { $live_location:
          ensure => 'directory',
        }

        pe_hocon_setting { "${file_sync_repo_setting}.live-dir":
          ensure  => present,
          setting => "${file_sync_repo_setting}.live-dir",
          value   => $live_location,
        }
      } else {
        # If we aren't running a staging dir, the source still refers to it as a "staging dir"
        $source_staging_dir = $live_location
      }

      file { $source_staging_dir:
        ensure => 'directory',
      }
    }
    'replica': {
      pe_hocon_setting { "${file_sync_repo_setting}.live-dir":
        ensure  => present,
        setting => "${file_sync_repo_setting}.live-dir",
        value   => $live_location,
      }
    }
  }

  pe_hocon_setting { "${file_sync_repo_setting}.staging-dir":
    ensure  => $present_if_is_source,
    setting => "${file_sync_repo_setting}.staging-dir",
    value   => $source_staging_dir,
  }

  pe_hocon_setting { "${file_sync_repo_setting}.client-active":
    ensure  => $present_if_is_source,
    setting => "${file_sync_repo_setting}.client-active",
    value   => $client_active,
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
}
