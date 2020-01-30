#!/bin/bash

# Determine paths to certs.
certname="$(/opt/puppetlabs/puppet/bin/puppet agent --configprint certname)"
certdir="$(/opt/puppetlabs/puppet/bin/puppet agent --configprint certdir)"

# Set variables for the curl.
cert="${certdir}/${certname}.pem"
key="$(/opt/puppetlabs/puppet/bin/puppet agent --configprint privatekeydir)/${certname}.pem"
cacert="${certdir}/ca.pem"

/opt/puppetlabs/puppet/bin/curl -kv -s \
    --request POST \
    --header "Content-Type: application/json" \
    --data "{\"repo-id\": \"${PT_repo_id}\"}" \
    --cert "$cert" \
    --key "$key" \
    --cacert "$cacert" \
    "https://$(hostname -f):8140/file-sync/v1/commit"