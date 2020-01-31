require 'puppet_x/external_data/forager/example'
require 'puppet_x/external_data/cache'

describe Puppet_X::ExternalData::Forager::Example do
  let(:cache) { Puppet_X::ExternalData::Cache.new }
  let(:forager) { described_class.new(cache: cache) }

  it 'has a name' do
    expect(forager.name).to be_a(String)
  end

  it 'has a type' do
    valid_types = [
      :ondemand,
      :ondemand_cached,
      :batch,
    ]

    expect(valid_types).to include(forager.type)
  end

  it 'returns example data' do
    expect(forager.get_data('foo.example.com')).to be_a(Hash)
  end

  it 'returns unchaged a second time' do
    expect(forager.get_data('foo.example.com')).to be_a(Hash)
    expect(forager.get_data('foo.example.com')).to be(nil)
  end
end
