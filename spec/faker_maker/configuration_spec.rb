# frozen_string_literal: true

RSpec.describe FakerMaker::Configuration do
  context 'auditing' do
    it 'can enable auditing' do
      config = FakerMaker::Configuration.new
      expect(config.audit = true).to be true
    end

    it 'is disabled by default' do
      config = FakerMaker::Configuration.new
      expect(config.audit?).to be false
    end

    it 'uses STDOUT by default' do
      config = FakerMaker::Configuration.new
      expect(config.audit_destination).to eq $stdout
    end

    it 'allows the setting of the audit destination' do
      config = FakerMaker::Configuration.new
      expect(config.audit_destination = '/tmp/audit_destination').to eq '/tmp/audit_destination'
    end
  end
end

RSpec.describe FakerMaker::Configurable do
  let(:dummy_class) { Class.new { extend FakerMaker::Configurable } }

  it 'gives access to a configuration object' do
    conf = dummy_class.configuration
    expect(conf).not_to be nil
    expect(conf).to be_kind_of(FakerMaker::Configuration)
  end

  it 'allows the configuration object to be set' do
    conf = FakerMaker::Configuration.new
    dummy_class.configuration = conf
    expect(dummy_class.configuration).to be conf
  end

  it 'yields the configuration object' do
    configuration_mock = double
    allow(dummy_class).to receive(:config).and_yield(configuration_mock)
    config_object = nil
    dummy_class.config { |c| config_object = c }
    expect(config_object).to be configuration_mock
  end
end
