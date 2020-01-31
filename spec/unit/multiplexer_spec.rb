require 'puppet_x/external_data/multiplexer'

describe Puppet_X::ExternalData::Multiplexer do
  let(:multiplexer) do
    configpath = File.expand_path('../example_config.yaml', __dir__)
    described_class.new(configpath)
  end

  it 'initialises and has the correct settings' do
    expect(multiplexer.foragers).to be_a(Array)
    expect(multiplexer.foragers[0]).to be_a(Puppet_X::ExternalData::Forager::Example)
    expect(multiplexer.cache).to be_a(Puppet_X::ExternalData::Cache::None)
  end
end