RSpec.describe FakerMaker::Base do

  let(:dummy_class) { Class.new { extend FakerMaker::Base } }


  it 'creates and registers factories' do
    factory = dummy_class.factory( :base_factory, {} ){ 'hello' }
    expect( FakerMaker[:base_factory] ).to eq factory
  end

end