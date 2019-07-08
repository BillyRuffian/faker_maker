RSpec.describe FakerMaker::Factory do
  it 'has a name' do
    factory = FakerMaker::Factory.new( :user )
    FakerMaker.register_factory( factory )
    expect( factory.name ).to eq :user
  end

  it 'will classify the class name' do
    factory = FakerMaker::Factory.new( :admin_user )
    FakerMaker.register_factory( factory )
    expect( factory.class_name ).to eq 'AdminUser'
  end

  it 'returns attributes' do
    factory = FakerMaker::Factory.new( :post )
    attributes = [FakerMaker::Attribute.new( :date, nil ), FakerMaker::Attribute.new( :title, nil )]
    attributes.each { |a| factory.attach_attribute( a ) }
    FakerMaker.register_factory( factory )
    expect( factory.attributes).to eq attributes
  end

  it 'acknowledges parentage' do
    parent = FakerMaker::Factory.new( :a )
    FakerMaker.register_factory( parent )
    child = FakerMaker::Factory.new( :b, parent: :a )
    FakerMaker.register_factory( child )

    expect( parent.parent? ).to be false
    expect( child.parent? ).to be true
    expect( child.parent ).to eq parent.name
  end

  it 'respects the class hierarchy' do
    parent = FakerMaker::Factory.new( :parent )
    parent_attributes = [FakerMaker::Attribute.new( :date ), FakerMaker::Attribute.new( :title )]
    parent_attributes.each { |a| parent.attach_attribute( a ) }
    FakerMaker.register_factory( parent )

    child = FakerMaker::Factory.new( :child, parent: :parent )
    child_attributes = [FakerMaker::Attribute.new( :author ), FakerMaker::Attribute.new( :content )]
    child_attributes.each { |a| child.attach_attribute( a ) }
    FakerMaker.register_factory( child )

    fake = Child.new

    expect( fake ).to respond_to( :date )
    expect( fake ).to respond_to( :title )
    expect( fake ).to respond_to( :author )
    expect( fake ).to respond_to( :content )
  end

  it 'builds populated objects' do
    factory = FakerMaker::Factory.new( :c )
    attr = FakerMaker::Attribute.new( :sample, proc { 'sample' } )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

    expect( factory.build.sample ).to eq 'sample'
  end
  
  it 'allows attribute overrides' do
    factory = FakerMaker::Factory.new( :overrides )
    attr1 = FakerMaker::Attribute.new( :first, proc { 'sample' } )
    attr2 = FakerMaker::Attribute.new( :second, proc { 'value' } )
    factory.attach_attribute( attr1 )
    factory.attach_attribute( attr2 )
    FakerMaker.register_factory( factory )
    
    sample = factory.build( second: 'overridden' )
    expect( sample.first ).to eq 'sample'
    expect( sample.second ).to eq 'overridden'
  end
  
  it 'allows attribute overrides with nil' do
    factory = FakerMaker::Factory.new( :overrides )
    attr1 = FakerMaker::Attribute.new( :first, proc { 'sample' } )
    factory.attach_attribute( attr1 )
    FakerMaker.register_factory( factory )
    
    sample = factory.build( first: nil )
    expect( sample.first ).to be nil
  end

  it 'generates JSON' do
    factory = FakerMaker::Factory.new( :d )
    attr = FakerMaker::Attribute.new( :sample, proc { 'sample' } )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

    expect( factory.build.sample ).to respond_to :to_json
    expect( factory.to_json ).to be_a String
  end

  it 'generates JSON and translates keys' do
    factory = FakerMaker::Factory.new( :f )
    attr = FakerMaker::Attribute.new( :sample, proc { 'JSON' }, json: 'jsonSample' )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

    expect( factory.to_json ).to include 'jsonSample' 
    expect( factory.to_json ).not_to include 'sample' 
  end

  it 'builds objects with arrays of attributes' do
    factory = FakerMaker::Factory.new( :e )
    attr = FakerMaker::Attribute.new( :sample, proc { 'sample' }, has: 2 )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

    fake = factory.build

    expect( fake.sample ).to be_a Array 
    expect( fake.sample.count ).to eq 2
  end
end
