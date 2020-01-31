require 'puppet_x/external_data/multiplexer'

describe Puppet_X::ExternalData::Multiplexer do
  let(:config_file) { File.expand_path('../example_config.yaml', __dir__) }
  let(:multiplexer) { described_class.new(config_file) }

  it 'initialises and has the correct settings' do
    expect(multiplexer.foragers).to be_a(Array)
    expect(multiplexer.foragers[0]).to be_a(Puppet_X::ExternalData::Forager::Example)
    expect(multiplexer.cache).to be_a(Puppet_X::ExternalData::Cache::None)
  end

  it 'returns data' do
    expect(multiplexer.get('retuns.data.com')).to eq(
      'example' => {
        'certname' => 'retuns.data.com',
        'colour'   => 'red',
        'rot13'    => 'erghaf.qngn.pbz',
        'upcase'   => 'RETUNS.DATA.COM',
      },
    )
  end

  it 'handles caching' do
    expect(multiplexer.get('handles.caching.com')).to eq(
      'example' => {
        'certname' => 'handles.caching.com',
        'colour'   => 'red',
        'rot13'    => 'unaqyrf.pnpuvat.pbz',
        'upcase'   => 'HANDLES.CACHING.COM',
      },
    )

    expect(multiplexer.get('handles.caching.com')).to eq(
      'example' => {
        'certname' => 'handles.caching.com',
        'colour'   => 'red',
        'rot13'    => 'unaqyrf.pnpuvat.pbz',
        'upcase'   => 'HANDLES.CACHING.COM',
      },
    )
  end
end
