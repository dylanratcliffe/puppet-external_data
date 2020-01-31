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

  context 'when using all methods' do
    let(:cache) { Puppet_X::ExternalData::Cache::Example.new }

    it 'returns data from data_for()' do
      expect(forager.data_for('return.example.com')).to be_a(Hash)
    end

    it 'stores data to the cache' do
      expect(cache).to receive(:update).and_call_original
      expect(forager.data_for('store.example.com')).to be_a(Hash)
    end

    it 'returns data from the cache' do
      expect(cache).to receive(:update).and_call_original
      expect(cache).to receive(:get).and_call_original
      expect(forager.data_for('get.example.com')).to be_a(Hash)
      expect(forager.data_for('get.example.com')).to be_a(Hash)
    end
  end
end
