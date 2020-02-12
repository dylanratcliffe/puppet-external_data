require 'puppet_x/external_data/multiplexer'

# Helper that gets the config from a known location
def config_filepath(name)
  File.expand_path("../fixtures/configs/#{name}.yaml", __dir__)
end

describe Puppet_X::ExternalData::Multiplexer do
  context 'with good config file' do
    let(:config_file) { config_filepath('example_config') }
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

  context 'with config options' do
    let(:config_file) { config_filepath('with_options') }
    let(:multiplexer) { described_class.new(config_file) }

    it 'passes them to the forager' do
      expect(multiplexer.foragers.length).to eq(1)
      expect(multiplexer.foragers.first).to be_a(Puppet_X::ExternalData::Forager::Example)
      expect(multiplexer.get('config.options.com')['example']['colour']).to eq('blue')
    end
  end

  context 'with unused options' do
    let(:config_file) { config_filepath('with_unused_options') }
    let(:multiplexer) { described_class.new(config_file) }

    it 'doesn\'t fail' do
      expect(multiplexer.foragers.length).to eq(1)
      expect(multiplexer.foragers.first).to be_a(Puppet_X::ExternalData::Forager::Example)
      expect(multiplexer.get('unused.options.com')['example']['colour']).to eq('blue')
    end
  end

  context 'with invalid settings' do
    let(:config_file) { config_filepath('with_invalid_options') }

    it 'fails nicely' do
      expect { described_class.new(config_file) }.to raise_error(%r{options})
    end
  end

  context 'without options' do
    let(:config_file) { config_filepath('without_options') }
    let(:multiplexer) { described_class.new(config_file) }

    it 'uses defaults' do
      expect(multiplexer.foragers.length).to eq(1)
      expect(multiplexer.foragers.first).to be_a(Puppet_X::ExternalData::Forager::Example)
      expect(multiplexer.get('without.options.com')['example']['colour']).to eq('not specified')
    end
  end

  context 'without a config file' do
    context 'because it wasn\'t set' do
      it 'fails nicely' do
        expect { described_class.new }.to raise_error(%r{No config file specified})
      end
    end

    context 'because it doesn\'t exist' do
      let(:config_file) { config_filepath('doesnt_exist') }

      it 'fails nicely' do
        expect { described_class.new(config_file) }.to raise_error(%r{doesnt_exist.yaml})
      end
    end
  end

  context 'with an invalid YAML file' do
    let(:config_file) { config_filepath('invalid_yaml') }

    it 'fails nicely' do
      expect { described_class.new(config_file) }.to raise_error(%r{invalid_yaml.yaml})
    end
  end
end
