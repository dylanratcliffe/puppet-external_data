#!/bin/bash

cat << EOF > /tmp/pe.conf
{
  "console_admin_password": "puppetlabs"
  "puppet_enterprise::puppet_master_host": "%{::trusted.certname}"

  # Additional customization
  "puppet_enterprise::profile::master::check_for_updates": false
  "puppet_enterprise::send_analytics_data": false

  "puppet_enterprise::master::puppetserver::jruby_max_active_instances": 1
  "puppet_enterprise::profile::master::java_args": { Xmx: "1024m", Xms: "128m" }
  "puppet_enterprise::profile::puppetdb::java_args": { Xmx: "512m", Xms: "64m" }
  "puppet_enterprise::profile::console::java_args": { Xmx: "256m", Xms: "64m" }
  "puppet_enterprise::profile::orchestrator::java_args": { Xmx: "256m", Xms: "64m" }
}
EOF


# Remove existing stuff
rm -rf /tmp/pe.tar.gz /tmp/pe

# Get the RHEL version
major_version=$(rpm -q --queryformat '%{RELEASE}' rpm | grep -o [[:digit:]]*\$)

# Download PE
curl -L -o /tmp/pe.tar.gz "https://pm.puppet.com/cgi-bin/download.cgi?dist=el&rel=$major_version&arch=x86_64&ver=$PT_version"

# Extract
mkdir -p /tmp/pe
tar zxf /tmp/pe.tar.gz --strip 1 -C /tmp/pe

# Install
/tmp/pe/puppet-enterprise-installer -c /tmp/pe.conf
