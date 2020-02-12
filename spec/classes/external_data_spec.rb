require 'spec_helper'

describe 'external_data' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'config' => {
            'cache' => {
              'name' => 'none',
            },
            'foragers' => [
              {
                'name'    => 'example',
                'options' => {
                  'colour' => 'red',
                },
              },
            ],
          },
        }
      end

      it { is_expected.to compile }
    end
  end
end
