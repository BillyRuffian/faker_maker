# frozen_string_literal: true

RSpec.describe FakerMaker do
  let( :factory ) { FakerMaker.register_factory( FakerMaker::Factory.new( :placeholder ) ) }

  it 'has a version number' do
    expect(FakerMaker::VERSION).not_to be nil
  end

  it 'finds a registered factory' do
    expect( FakerMaker[factory.name] ).to eq factory
  end

  it 'builds objects from a factory' do
    expect( FakerMaker.build( :placeholder ) ).to be_a Placeholder
  end
  
  it 'raises an error if the factory doesn\'t exist' do
    expect { FakerMaker[:'non existent factory'] }.to raise_error( FakerMaker::NoSuchFactoryError )
  end
end
