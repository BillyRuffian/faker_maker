# frozen_string_literal: true

RSpec.describe FakerMaker::DefinitionProxy do
  it 'dynamically creates attributes' do
    factory = FakerMaker::Factory.new( :definition_proxy )
    proxy = FakerMaker::DefinitionProxy.new( factory )
    proxy.send( :a_new_attribute ) { 'hello' }
    expect( factory.attributes.map( &:name ) ).to include( :a_new_attribute )
  end

  context '#faker_maker_factory' do
    it 'returns the factory object' do
      factory = FakerMaker::Factory.new( :definition_proxy )
      proxy = FakerMaker::DefinitionProxy.new( factory )
      expect(proxy.faker_maker_factory).to be factory
    end
  end
end
