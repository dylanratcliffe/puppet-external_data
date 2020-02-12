require 'spec_helper_acceptance'

before(:all) do
  host_pp = <<-PUPPETCODE
    host { 'puppet':
      ip => $facts['networking']['ip'],
    }
  PUPPETCODE
  idempotent_apply(host_pp)
  shell('puppet config set')
end

context 'with example config' do
  before(:all) do
    scp_to(default, 'spec/fixtures/configs/example_config.yaml', '/etc/puppetlabs/puppet/external_data.yaml')
  end


end