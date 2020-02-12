require 'spec_helper_acceptance'

def server_status
  run_shell('curl -k https://127.0.0.1:8140/status/v1/simple', expect_failures: true).stdout
end

context 'with example config', wait: { timeout: 60 } do
  it 'configures itself' do
    config_pp = <<-PUPPETCODE
      host { 'puppet':
        ip => $facts['networking']['ip'],
      }

      class { 'external_data':
        puppetserver_user => 'puppet',
        config => {
          'cache'    => {
            'name' => 'none',
          },
          'foragers' => [
            {
              'name'    => 'example',
              'options' => {
                'colour' => 'red',
              }
            }
          ]
        },
        notify => Exec['HUP puppetserver'],
      }

      exec { 'HUP puppetserver':
        command     => 'pkill -HUP java',
        path        => $facts['path'],
        refreshonly => true,
      }
    PUPPETCODE

    wait_for { server_status }.to eq('running')
    idempotent_apply(config_pp)
    wait_for { server_status }.to eq('running')
  end

  it 'can run puppet agent' do
    wait_for { server_status }.to eq('running')
    expect(run_shell('puppet agent -t').exit_code).to be(0)
  end
end
