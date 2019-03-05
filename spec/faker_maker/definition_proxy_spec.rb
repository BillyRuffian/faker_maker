RSpec.describe FakerMaker::DefinitionProxy do 

  it 'dynamically creates attributes' do
    factory = factory = FakerMaker::Factory.new( :definition_proxy )
    proxy = FakerMaker::DefinitionProxy.new( factory )
    attribute = proxy.send( :a_new_attribute ){ 'hello' }
    expect( factory.attributes.map( &:name ) ).to include( :a_new_attribute )
  end

end