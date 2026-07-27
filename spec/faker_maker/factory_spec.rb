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

    sample = factory.build( attributes: { second: 'overridden' } )
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

    fake = child.build( attributes: { author: 'Teresa Greene', title: 'A Title' } )
    expect( fake.author ).to eq 'Teresa Greene'
    expect( fake.title ).to eq 'A Title'
  end

  it 'allows attribute overrides with nil' do
    factory = FakerMaker::Factory.new( :overrides )
    attr1 = FakerMaker::Attribute.new( :first, proc { 'sample' } )
    factory.attach_attribute( attr1 )
    FakerMaker.register_factory( factory )

    sample = factory.build( attributes: { first: nil } )
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

    it 'preserves explicitly overridden attributes when chaos is enabled' do
      factory = FakerMaker::Factory.new( :example_factory )
      required_attribute = FakerMaker::Attribute.new( :required_attribute, proc { 'required' }, required: true )
      optional_attribute = FakerMaker::Attribute.new( :optional_attribute, proc { 'optional' } )
      factory.attach_attribute( required_attribute )
      factory.attach_attribute( optional_attribute )
      FakerMaker.register_factory( factory )

      fakes = []
      10.times do
        fakes << factory.build( attributes: { optional_attribute: 'overridden' }, chaos: true )
      end

      fakes.each do |fake|
        expect( fake.optional_attribute ).to eq 'overridden'
      end
    end
  end

  describe 'embedded factories' do
    it 'builds a factory with multiple embedded factories' do
      first_embed = FakerMaker::Factory.new( :first_embed )
      first_embed.attach_attribute( FakerMaker::Attribute.new( :colour, proc { 'red' } ) )
      FakerMaker.register_factory( first_embed )

      second_embed = FakerMaker::Factory.new( :second_embed )
      second_embed.attach_attribute( FakerMaker::Attribute.new( :size, proc { 'large' } ) )
      FakerMaker.register_factory( second_embed )

      factory = FakerMaker::Factory.new( :multi_embed )
      factory.attach_attribute( FakerMaker::Attribute.new( :name, proc { 'test' }, required: true ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :variant, nil, factory: %i[first_embed second_embed] ) )
      FakerMaker.register_factory( factory )

      expect { factory.build }.not_to raise_error

      fake = factory.build
      variant = fake.variant
      expect( variant ).to satisfy { |v| v.respond_to?(:colour) || v.respond_to?(:size) }
    end

    it 'builds with chaos mode enabled on a factory with embedded factories' do
      embed = FakerMaker::Factory.new( :chaos_embed )
      embed.attach_attribute( FakerMaker::Attribute.new( :value, proc { 'embedded' } ) )
      FakerMaker.register_factory( embed )

      factory = FakerMaker::Factory.new( :chaos_parent )
      factory.attach_attribute( FakerMaker::Attribute.new( :title, proc { 'hello' }, required: true ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :child, nil, factory: :chaos_embed ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :optional_field, proc { 'maybe' } ) )
      FakerMaker.register_factory( factory )

      expect { factory.build( chaos: true ) }.not_to raise_error
    end

    it 'allows chaos mode to target an embedded factory attribute' do
      embed = FakerMaker::Factory.new( :target_embed )
      embed.attach_attribute( FakerMaker::Attribute.new( :value, proc { 'embedded' } ) )
      FakerMaker.register_factory( embed )

      factory = FakerMaker::Factory.new( :target_parent )
      factory.attach_attribute( FakerMaker::Attribute.new( :title, proc { 'hello' }, required: true ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :child, nil, factory: :target_embed ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :optional_field, proc { 'maybe' } ) )
      FakerMaker.register_factory( factory )

      expect { factory.build( chaos: [:child] ) }.not_to raise_error

      fakes = []
      10.times { fakes << factory.build( chaos: [:child] ) }

      fakes.each { |fake| expect( fake.title ).to eq 'hello' }
      fakes.each { |fake| expect( fake.optional_field ).to eq 'maybe' }
      expect( fakes.map(&:child) ).to include nil
    end

    it 'does not pass parent chaos attribute names to child factories' do
      embed = FakerMaker::Factory.new( :leak_embed )
      embed.attach_attribute( FakerMaker::Attribute.new( :inner_value, proc { 'inner' }, required: true ) )
      FakerMaker.register_factory( embed )

      factory = FakerMaker::Factory.new( :leak_parent )
      factory.attach_attribute( FakerMaker::Attribute.new( :name, proc { 'parent' }, required: true ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :child, nil, factory: :leak_embed ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :optional_thing, proc { 'optional' } ) )
      FakerMaker.register_factory( factory )

      expect { factory.build( chaos: [:optional_thing] ) }.not_to raise_error

      fake = factory.build( chaos: [:optional_thing] )
      expect( fake.child.inner_value ).to eq 'inner'
    end
  end

  describe 'overriding embedded factory attributes' do
    it 'allows FakerMaker::OMIT to be passed as an override for an embedded factory attribute' do
      embed = FakerMaker::Factory.new( :override_embed )
      embed.attach_attribute( FakerMaker::Attribute.new( :street, proc { '123 High St' } ) )
      embed.attach_attribute( FakerMaker::Attribute.new( :city, proc { 'Swansea' } ) )
      FakerMaker.register_factory( embed )

      factory = FakerMaker::Factory.new( :override_parent )
      factory.attach_attribute( FakerMaker::Attribute.new( :name, proc { 'Alice' } ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :address, nil, factory: :override_embed ) )
      FakerMaker.register_factory( factory )

      fake = factory.build( attributes: { address: FakerMaker::OMIT } )
      expect( fake.address ).to eq FakerMaker::OMIT
    end

    it 'omits the embedded factory attribute from JSON when overridden with FakerMaker::OMIT' do
      embed = FakerMaker::Factory.new( :override_embed )
      embed.attach_attribute( FakerMaker::Attribute.new( :street, proc { '123 High St' } ) )
      embed.attach_attribute( FakerMaker::Attribute.new( :city, proc { 'Swansea' } ) )
      FakerMaker.register_factory( embed )

      factory = FakerMaker::Factory.new( :override_parent )
      factory.attach_attribute( FakerMaker::Attribute.new( :name, proc { 'Alice' } ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :address, nil, factory: :override_embed ) )
      FakerMaker.register_factory( factory )

      fake = factory.build( attributes: { address: FakerMaker::OMIT } )
      expect( fake.as_json ).not_to have_key 'address'
    end

    it 'allows nil to be passed as an override for an embedded factory attribute' do
      embed = FakerMaker::Factory.new( :override_embed )
      embed.attach_attribute( FakerMaker::Attribute.new( :street, proc { '123 High St' } ) )
      embed.attach_attribute( FakerMaker::Attribute.new( :city, proc { 'Swansea' } ) )
      FakerMaker.register_factory( embed )

      factory = FakerMaker::Factory.new( :override_parent )
      factory.attach_attribute( FakerMaker::Attribute.new( :name, proc { 'Alice' } ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :address, nil, factory: :override_embed ) )
      FakerMaker.register_factory( factory )

      fake = factory.build( attributes: { address: nil } )
      expect( fake.address ).to be_nil
    end

    it 'still passes Hash overrides through to the embedded factory' do
      embed = FakerMaker::Factory.new( :override_embed )
      embed.attach_attribute( FakerMaker::Attribute.new( :street, proc { '123 High St' } ) )
      embed.attach_attribute( FakerMaker::Attribute.new( :city, proc { 'Swansea' } ) )
      FakerMaker.register_factory( embed )

      factory = FakerMaker::Factory.new( :override_parent )
      factory.attach_attribute( FakerMaker::Attribute.new( :name, proc { 'Alice' } ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :address, nil, factory: :override_embed ) )
      FakerMaker.register_factory( factory )

      fake = factory.build( attributes: { address: { street: '456 Low Rd' } } )
      expect( fake.address.street ).to eq '456 Low Rd'
      expect( fake.address.city ).to eq 'Swansea'
    end

    it 'allows an empty Hash to be passed as an override, bypassing the embedded factory' do
      embed = FakerMaker::Factory.new( :override_embed )
      embed.attach_attribute( FakerMaker::Attribute.new( :street, proc { '123 High St' } ) )
      embed.attach_attribute( FakerMaker::Attribute.new( :city, proc { 'Swansea' } ) )
      FakerMaker.register_factory( embed )

      factory = FakerMaker::Factory.new( :override_parent )
      factory.attach_attribute( FakerMaker::Attribute.new( :name, proc { 'Alice' } ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :address, nil, factory: :override_embed ) )
      FakerMaker.register_factory( factory )

      fake = factory.build( attributes: { address: {} } )
      expect( fake.address ).to eq( {} )
    end

    it 'renders an empty Hash override as {} in JSON output' do
      embed = FakerMaker::Factory.new( :override_embed )
      embed.attach_attribute( FakerMaker::Attribute.new( :street, proc { '123 High St' } ) )
      embed.attach_attribute( FakerMaker::Attribute.new( :city, proc { 'Swansea' } ) )
      FakerMaker.register_factory( embed )

      factory = FakerMaker::Factory.new( :override_parent )
      factory.attach_attribute( FakerMaker::Attribute.new( :name, proc { 'Alice' } ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :address, nil, factory: :override_embed ) )
      FakerMaker.register_factory( factory )

      fake = factory.build( attributes: { address: {} } )
      expect( fake.as_json[:address] ).to eq( {} )
    end
  end

  describe 'selecting embedded factories based on overrides' do
    it 'selects the factory whose attributes match the override keys' do
      address = FakerMaker::Factory.new( :sel_address )
      address.attach_attribute( FakerMaker::Attribute.new( :street, proc { '1 High St' } ) )
      address.attach_attribute( FakerMaker::Attribute.new( :city, proc { 'London' } ) )
      FakerMaker.register_factory( address )

      billing = FakerMaker::Factory.new( :sel_billing )
      billing.attach_attribute( FakerMaker::Attribute.new( :card_number, proc { '4111' } ) )
      billing.attach_attribute( FakerMaker::Attribute.new( :expiry, proc { '12/30' } ) )
      FakerMaker.register_factory( billing )

      factory = FakerMaker::Factory.new( :sel_customer )
      factory.attach_attribute( FakerMaker::Attribute.new( :name, proc { 'Alice' } ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :info, nil, factory: %i[sel_address sel_billing] ) )
      FakerMaker.register_factory( factory )

      20.times do
        fake = factory.build( attributes: { info: { card_number: '9999' } } )
        expect( fake.info ).to respond_to( :card_number )
        expect( fake.info ).not_to respond_to( :street )
        expect( fake.info.card_number ).to eq '9999'
      end
    end

    it 'selects from among multiple matching factories' do
      uk_addr = FakerMaker::Factory.new( :sel_uk_address )
      uk_addr.attach_attribute( FakerMaker::Attribute.new( :street, proc { 'High St' } ) )
      uk_addr.attach_attribute( FakerMaker::Attribute.new( :postcode, proc { 'SW1A 1AA' } ) )
      FakerMaker.register_factory( uk_addr )

      us_addr = FakerMaker::Factory.new( :sel_us_address )
      us_addr.attach_attribute( FakerMaker::Attribute.new( :street, proc { 'Main St' } ) )
      us_addr.attach_attribute( FakerMaker::Attribute.new( :zip_code, proc { '10001' } ) )
      FakerMaker.register_factory( us_addr )

      phone = FakerMaker::Factory.new( :sel_phone )
      phone.attach_attribute( FakerMaker::Attribute.new( :number, proc { '555-0100' } ) )
      FakerMaker.register_factory( phone )

      factory = FakerMaker::Factory.new( :sel_contact )
      factory.attach_attribute( FakerMaker::Attribute.new( :label, proc { 'home' } ) )
      factory.attach_attribute( FakerMaker::Attribute.new( :detail, nil, factory: %i[sel_uk_address sel_us_address sel_phone] ) )
      FakerMaker.register_factory( factory )

      results = 30.times.map { factory.build( attributes: { detail: { street: '1 Elm Rd' } } ) }

      results.each do |fake|
        expect( fake.detail ).to respond_to( :street )
        expect( fake.detail ).not_to respond_to( :number )
      end
      expect( results.any? { |f| f.detail.respond_to?( :postcode ) } ).to be true
      expect( results.any? { |f| f.detail.respond_to?( :zip_code ) } ).to be true
    end

    it 'raises NoSuchFactoryError when overrides match no embedded factory' do
      alpha = FakerMaker::Factory.new( :sel_alpha )
      alpha.attach_attribute( FakerMaker::Attribute.new( :a_val, proc { 'a' } ) )
      FakerMaker.register_factory( alpha )

      beta = FakerMaker::Factory.new( :sel_beta )
      beta.attach_attribute( FakerMaker::Attribute.new( :b_val, proc { 'b' } ) )
      FakerMaker.register_factory( beta )

      factory = FakerMaker::Factory.new( :sel_no_match )
      factory.attach_attribute( FakerMaker::Attribute.new( :content, nil, factory: %i[sel_alpha sel_beta] ) )
      FakerMaker.register_factory( factory )

      expect { factory.build( attributes: { content: { unknown_key: 'x' } } ) }
        .to raise_error( FakerMaker::NoSuchFactoryError, /Unable to match given attributes/ )
    end

    it 'randomly selects from all factories when no overrides are given' do
      opt_x = FakerMaker::Factory.new( :sel_opt_x )
      opt_x.attach_attribute( FakerMaker::Attribute.new( :x_val, proc { 'x' } ) )
      FakerMaker.register_factory( opt_x )

      opt_y = FakerMaker::Factory.new( :sel_opt_y )
      opt_y.attach_attribute( FakerMaker::Attribute.new( :y_val, proc { 'y' } ) )
      FakerMaker.register_factory( opt_y )

      factory = FakerMaker::Factory.new( :sel_random_pick )
      factory.attach_attribute( FakerMaker::Attribute.new( :choice, nil, factory: %i[sel_opt_x sel_opt_y] ) )
      FakerMaker.register_factory( factory )

      results = 30.times.map { factory.build }
      expect( results.any? { |f| f.choice.respond_to?( :x_val ) } ).to be true
      expect( results.any? { |f| f.choice.respond_to?( :y_val ) } ).to be true
    end

    it 'narrows to the single factory matching all override keys' do
      broad = FakerMaker::Factory.new( :sel_broad )
      broad.attach_attribute( FakerMaker::Attribute.new( :alpha, proc { 'a' } ) )
      broad.attach_attribute( FakerMaker::Attribute.new( :beta, proc { 'b' } ) )
      broad.attach_attribute( FakerMaker::Attribute.new( :gamma, proc { 'g' } ) )
      FakerMaker.register_factory( broad )

      narrow = FakerMaker::Factory.new( :sel_narrow )
      narrow.attach_attribute( FakerMaker::Attribute.new( :alpha, proc { 'a' } ) )
      narrow.attach_attribute( FakerMaker::Attribute.new( :beta, proc { 'b' } ) )
      FakerMaker.register_factory( narrow )

      other = FakerMaker::Factory.new( :sel_other )
      other.attach_attribute( FakerMaker::Attribute.new( :delta, proc { 'd' } ) )
      FakerMaker.register_factory( other )

      factory = FakerMaker::Factory.new( :sel_multi_key )
      factory.attach_attribute( FakerMaker::Attribute.new( :item, nil, factory: %i[sel_broad sel_narrow sel_other] ) )
      FakerMaker.register_factory( factory )

      20.times do
        fake = factory.build( attributes: { item: { alpha: 'A', beta: 'B', gamma: 'G' } } )
        expect( fake.item ).to respond_to( :gamma )
        expect( fake.item ).not_to respond_to( :delta )
        expect( fake.item.alpha ).to eq 'A'
        expect( fake.item.beta ).to eq 'B'
        expect( fake.item.gamma ).to eq 'G'
      end
    end
  end

  describe '#instance' do
    it 'returns the instance' do
      factory = FakerMaker::Factory.new( :factory )
      expect(factory.instance).not_to be_nil
    end
  end
end
