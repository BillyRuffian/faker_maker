RSpec.describe FakerMaker::Attribute do

  it 'has a name' do
    attr = FakerMaker::Attribute.new( :my_name, {}, nil )
    expect( attr.name ).to eq :my_name
  end

  it 'has a block' do
    attr = FakerMaker::Attribute.new( :my_name, {}, Proc.new{ 'block' } )
    expect( attr.block ).to be_a Proc
  end

  it 'allows cardinality > 1' do
    attr = FakerMaker::Attribute.new( :my_name, {has: 10}, Proc.new{ 'block' } )
    expect( attr.cardinality ).to be 10
    expect( attr.array? ).to be true
  end

  it 'allow a range of cardinality' do
    attr = FakerMaker::Attribute.new( :my_name, {has: 1..5}, Proc.new{ 'block' } )
    expect( attr.cardinality ).to be_between( 1, 5 )
  end

  it 'allows arrays for cardinality of 1' do
    attr = FakerMaker::Attribute.new( :my_name, {array: true}, nil )
    expect( attr.array? ).to be true
  end

end