require 'puppet_x/external_data/metadata'
require 'puppet_x/external_data/cache'
require 'logger'

describe Puppet_X::ExternalData::Metadata do # rubocop:disable RSpec/FilePath
  let(:cache) { Puppet_X::ExternalData::Cache.new }
  let(:metadata) { described_class.new('example', cache) }

  it 'pulls metadata back' do
    expect(cache).to receive(:get).with('example', 'metadata-keyname').and_return(nil)
    expect(metadata['keyname']).to eq(nil)
  end

  it 'saves metadata' do
    expect(cache).to receive(:update).with('example', 'metadata-keyname', 'fish').and_return('fish')
    expect { metadata['keyname'] = 'fish' }.not_to raise_error
  end

  it 'deletes metadata' do
    expect(cache).to receive(:delete).with('example', 'metadata-keyname').and_return(nil)
    expect { metadata['keyname'] = nil }.not_to raise_error
  end
end
