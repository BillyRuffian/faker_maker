# frozen_string_literal: true

RSpec.describe FakerMaker do
  let( :factory ) { FakerMaker::Factory.new( :placeholder ) }

  it 'has a version number' do
    expect(FakerMaker::VERSION).not_to be nil
  end

  it 'finds a registered factory' do
    FakerMaker.register_factory(factory)
    expect( FakerMaker[factory.name] ).to eq factory
  end

  it 'warns if a factory is already registered' do
    FakerMaker.register_factory(factory)
    expect { FakerMaker.register_factory(factory) }.to output( /Factory 'placeholder' already registered/ ).to_stderr
  end

  it 'builds objects from a factory' do
    FakerMaker.register_factory(factory)
    expect( FakerMaker.build( :placeholder ) ).to be_a Placeholder
  end

  it 'raises an error if the factory doesn\'t exist' do
    expect { FakerMaker[:'non existent factory'] }.to raise_error( FakerMaker::NoSuchFactoryError )
  end

  describe '#shut!' do
    it 'removes the factory and its class' do
      factory = FakerMaker.register_factory( FakerMaker::Factory.new( :shut_me ) )
      expect( Object.const_get( factory.class_name) ).not_to be_nil
      FakerMaker.shut!( factory.name )
      expect { FakerMaker[factory.name] }.to raise_error( FakerMaker::NoSuchFactoryError )
      expect { Object.const_get( factory.class_name) }.to raise_error( NameError )
    end
  end

  describe '#shut_all!' do
    it 'closes all factories and removes their classes' do
      FakerMaker.register_factory( FakerMaker::Factory.new( :shut_me ) )
      factories = FakerMaker.factories
      FakerMaker.shut_all!
      factories.each do |name, factory|
        expect { FakerMaker[name] }.to raise_error( FakerMaker::NoSuchFactoryError )
        expect { Object.const_get( factory.class_name) }.to raise_error( NameError )
      end
    end
  end
end
