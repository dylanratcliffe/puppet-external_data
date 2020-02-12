require 'puppet_x/external_data/cache/none'

describe Puppet_X::ExternalData::Cache::None do # rubocop:disable RSpec/FilePath
  let(:cache) { described_class.new }

  it 'has the correct methods' do
    expect(cache).to respond_to(:get)
    expect(cache).to respond_to(:delete)
    expect(cache).to respond_to(:update)
  end

  it 'can store data' do
    data = {
      'foo' => 'bar',
    }

    expect(cache.update('test', 'foo.example.com', data)).to be(data)
    expect(cache.get('test', 'foo.example.com')).to be(data)
  end

  it 'can delete data' do
    data = {
      'foo' => 'bar',
    }

    expect(cache.update('test', 'foo.example.com', data)).to be(data)
    expect(cache.get('test', 'foo.example.com')).to be(data)
    cache.delete('test', 'foo.example.com')
    expect(cache.get('test', 'foo.example.com')).to be(nil)
  end
end
