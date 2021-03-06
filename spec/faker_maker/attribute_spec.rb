# frozen_string_literal: true

RSpec.describe FakerMaker::Attribute do
  it 'has a name' do
    attr = FakerMaker::Attribute.new( :my_name, nil, {} )
    expect( attr.name ).to eq :my_name
  end

  it 'has a block' do
    attr = FakerMaker::Attribute.new( :my_name, proc { 'block' } )
    expect( attr.block ).to be_a Proc
  end

  it 'can have a JSON alias' do
    attr = FakerMaker::Attribute.new( :my_name, proc { 'block' }, json: 'jsonString' )
    expect( attr.translation? ).to be true
    expect( attr.translation ).to eq 'jsonString'
  end

  it 'allows cardinality > 1' do
    attr = FakerMaker::Attribute.new( :my_name, proc { 'block' }, has: 10 )
    expect( attr.cardinality ).to be 10
    expect( attr.array? ).to be true
  end

  it 'allow a range of cardinality' do
    attr = FakerMaker::Attribute.new( :my_name, proc { 'block' }, has: 1..5 )
    expect( attr.cardinality ).to be_between( 1, 5 )
  end

  it 'allows arrays for cardinality of 1' do
    attr = FakerMaker::Attribute.new( :my_name, nil, array: true )
    expect( attr.array? ).to be true
  end

  it 'can omit nils' do
    attr = FakerMaker::Attribute.new( :my_name, nil, omit: :nil )
    expect( attr.omit?(nil) ).to be true
  end

  it 'can omit empty' do
    attr = FakerMaker::Attribute.new( :my_name, nil, omit: :empty )
    expect( attr.omit?('') ).to be true
  end

  it 'can omit always' do
    attr = FakerMaker::Attribute.new( :my_name, nil, omit: :always )
    expect( attr.omit?('anything') ).to be true
  end

  it 'can omit nils and empty' do
    attr = FakerMaker::Attribute.new( :my_name, nil, omit: %i[nil empty] )
    expect( attr.omit?('') ).to be true
    expect( attr.omit?(nil) ).to be true
    expect( attr.omit?('anything') ).to be false
  end
end
