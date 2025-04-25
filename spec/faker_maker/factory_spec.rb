# frozen_string_literal: true

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

    fake = FakerMaker::Factory::Child.new

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

  it 'allows attribute overrides with inheritance' do
    parent = FakerMaker::Factory.new( :parent )
    parent_attributes = [FakerMaker::Attribute.new( :date ), FakerMaker::Attribute.new( :title )]
    parent_attributes.each { |a| parent.attach_attribute( a ) }
    FakerMaker.register_factory( parent )

    child = FakerMaker::Factory.new( :child, parent: :parent )
    child_attributes = [FakerMaker::Attribute.new( :author ), FakerMaker::Attribute.new( :content )]
    child_attributes.each { |a| child.attach_attribute( a ) }
    FakerMaker.register_factory( child )

    fake = child.build( author: 'Teresa Greene', title: 'A Title' )
    expect( fake.author ).to eq 'Teresa Greene'
    expect( fake.title ).to eq 'A Title'
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

  it 'generates JSON and auto-translates keys to camelCase' do
    factory = FakerMaker::Factory.new( :h, naming: :json )
    attr = FakerMaker::Attribute.new( :this_is_a_key, proc { 'sample' } )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

    expect( factory.to_json ).to include 'thisIsAKey'
    expect( factory.to_json ).not_to include 'this_is_a_key'
  end

  it 'generates JSON and auto-translates keys to CamelCase' do
    factory = FakerMaker::Factory.new( :h, naming: :json_capitalised )
    attr = FakerMaker::Attribute.new( :this_is_a_key, proc { 'sample' } )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

    expect( factory.to_json ).to include 'ThisIsAKey'
    expect( factory.to_json ).not_to include 'this_is_a_key'
  end

  it 'generates JSON and translates auto-translated keys' do
    factory = FakerMaker::Factory.new( :i, naming: :json )
    attr = FakerMaker::Attribute.new( :this_is_a_key, proc { 'sample' }, json: 'overridenTranslation' )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

    expect( factory.to_json ).to include 'overridenTranslation'
    expect( factory.to_json ).not_to include 'thisIsAKey'
  end

  it 'generates JSON and omits attributes' do
    factory = FakerMaker::Factory.new( :g )
    attr = FakerMaker::Attribute.new( :sample, proc {}, omit: :nil )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

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

  it 'builds objects with attributes from embedded factories' do
    embed = FakerMaker::Factory.new( :embedded )
    attr = FakerMaker::Attribute.new( :sample, proc { 'sample' } )
    embed.attach_attribute( attr )
    FakerMaker.register_factory( embed )

    factory = FakerMaker::Factory.new( :factory )
    attr = FakerMaker::Attribute.new( :sample, nil, factory: %i[embedded] )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

    fake = factory.build
    expect( fake.sample ).to be_a embed.assemble
  end

  it 'calls the before hook' do
    factory = FakerMaker::Factory.new( :hook )
    proxy = FakerMaker::DefinitionProxy.new( factory )
    attr = FakerMaker::Attribute.new( :sample, proc { 'sample' } )
    factory.attach_attribute( attr )
    proxy.send(:before_build) { "value #{faker_maker_factory.instance.sample}" }
    expect(factory).to receive(:before_build).once
    factory.build
  end

  it 'calls the after hook' do
    factory = FakerMaker::Factory.new( :hook )
    proxy = FakerMaker::DefinitionProxy.new( factory )
    attr = FakerMaker::Attribute.new( :sample, proc { 'sample' } )
    factory.attach_attribute( attr )
    proxy.send(:after_build) { "value #{faker_maker_factory.instance.sample}" }
    expect(factory).to receive(:after_build).once
    factory.build
  end

  it 'overrides attribute values using keyword argument \'attributes:\' in build method' do
    factory = FakerMaker::Factory.new( :example_factory )
    attr = FakerMaker::Attribute.new( :example_attribute, proc { 'sample' } )
    factory.attach_attribute( attr )
    FakerMaker.register_factory( factory )

    fake = factory.build( attributes: { example_attribute: 'override' } )

    expect( fake.example_attribute ).to eq 'override'
  end

  describe 'chaos mode' do
    it 'can be enabled' do
      factory = FakerMaker::Factory.new( :example_factory )
      attr = FakerMaker::Attribute.new( :example_attribute, proc { 'sample' } )
      factory.attach_attribute( attr )
      FakerMaker.register_factory( factory )

      expect { factory.build( chaos: true ) }.not_to raise_error
    end

    it 'required fields are always present when in chaos mode' do
      factory = FakerMaker::Factory.new( :example_factory )
      required_attribute = FakerMaker::Attribute.new( :required_attribute, proc { 'required' }, required: true )
      optional_attribute = FakerMaker::Attribute.new( :optional_attribute, proc { 'optional' }, required: false )
      factory.attach_attribute( required_attribute )
      factory.attach_attribute( optional_attribute )
      FakerMaker.register_factory( factory )

      fakes = []
      10.times do
        fakes << factory.build( chaos: true )
      end

      fakes.each { |fake| expect(fake.required_attribute).to be_present }
      expect(fakes.map(&:optional_attribute)).to include nil
    end

    it 'allows specific attributes to be passed -- other optional attributes are treated as required' do
      factory = FakerMaker::Factory.new( :example_factory )
      required_attribute = FakerMaker::Attribute.new( :required_attribute, proc { 'required' }, required: true )
      optional_attribute = FakerMaker::Attribute.new( :optional_attribute, proc { 'optional' }, required: false )
      optional_attribute_two = FakerMaker::Attribute.new( :optional_attribute_two, proc {
                                                                                     'optional'
                                                                                   }, required: false )
      factory.attach_attribute( required_attribute )
      factory.attach_attribute( optional_attribute )
      factory.attach_attribute( optional_attribute_two )
      FakerMaker.register_factory( factory )

      fakes = []
      10.times do
        fakes << factory.build( chaos: %i[optional_attribute] )
      end

      fakes.each do |fake|
        expect(fake.required_attribute).to be_present
        expect(fake.optional_attribute_two).to be_present
      end
      expect(fakes.map(&:optional_attribute)).to include nil
    end

    it 'errors when you pass a required attribute' do
      factory = FakerMaker::Factory.new( :example_factory )
      required_attribute = FakerMaker::Attribute.new( :required_attribute, proc { 'required' }, required: true )
      optional_attribute = FakerMaker::Attribute.new( :optional_attribute, proc { 'optional' }, required: false )
      factory.attach_attribute( required_attribute )
      factory.attach_attribute( optional_attribute )
      FakerMaker.register_factory( factory )

      expect do
        factory.build( chaos: %i[required_attribute] )
      end.to raise_error(FakerMaker::ChaosConflictingAttributeError)
    end
  end

  describe '#instance' do
    it 'returns the instance' do
      factory = FakerMaker::Factory.new( :factory )
      expect(factory.instance).not_to be_nil
    end
  end
end
