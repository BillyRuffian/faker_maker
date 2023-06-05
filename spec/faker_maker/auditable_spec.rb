# frozen_string_literal: true

RSpec.describe FakerMaker::Auditable do
  let(:dummy_class) { Class.new { extend FakerMaker::Auditable } }

  it 'records details of the instance as a JSON string as the body element' do
    instance = { a: 'z' }
    output = StringIO.new
    FakerMaker.configuration.audit_destination = output
    dummy_class.audit(instance)
    expect(output.string).to match(/"body":.*#{instance.to_json}/)
  end

  context 'envelope metadata' do
    it 'captures a timestamp' do
      instance = { a: 'z' }
      output = StringIO.new
      FakerMaker.configuration.audit_destination = output
      dummy_class.audit(instance)
      expect(output.string).to match(/"timestamp":.*\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[-+]\d{2}:\d{2}/)
    end

    it 'captures a the instance class name' do
      instance = { a: 'z' }
      output = StringIO.new
      FakerMaker.configuration.audit_destination = output
      dummy_class.audit(instance)
      expect(output.string).to match(/"class":"Hash"/)
    end

    it 'captures a the factory class name' do
      instance = { a: 'z' }
      output = StringIO.new
      FakerMaker.configuration.audit_destination = output
      dummy_class.audit(instance)
      expect(output.string).to match(/"factory":""/) # dynamically build classes have no name
    end
  end
end
