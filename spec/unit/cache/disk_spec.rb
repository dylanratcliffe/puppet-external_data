require 'puppet_x/external_data/cache/disk'
require 'tmpdir'
require 'fileutils'
require 'securerandom'

# We need to use these sure ensure that tempfiles are cleaned up
# rubocop:disable RSpec/BeforeAfterAll
# rubocop:disable RSpec/InstanceVariable

describe Puppet_X::ExternalData::Cache::Disk do # rubocop:disable RSpec/FilePath
  before(:all) { @dir = File.join(Dir.tmpdir, SecureRandom.alphanumeric) }
  let(:cache) { described_class.new(path: @dir) }

  it 'has a _get method' do
    expect(cache).to respond_to(:_get)
  end

  it 'has a _delete method' do
    expect(cache).to respond_to(:_delete)
  end

  it 'has a _update method' do
    expect(cache).to respond_to(:_update)
  end

  it 'returns nothing when nothing is there' do
    expect(cache.get('foobar', 'something.com')).to be(nil)
  end

  it 'handles deleting of nothing is there' do
    expect(cache.delete('foobar', 'something.com')).to be(nil)
  end

  it 'creates records' do
    expect(cache.update('foobar', 'something.com', 'foo' => 'bar')).to eq('foo' => 'bar')
  end

  it 'reads them back' do
    expect(cache.get('foobar', 'something.com')).to eq('foo' => 'bar')
  end

  after(:all) do
    FileUtils.rm_rf(@dir)
  end
end
