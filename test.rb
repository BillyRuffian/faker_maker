FakerMaker.factory :Foo, class: 'FooBar' do 
  bob {'hey'} 
end

FakerMaker.factory :bar, parent: :Foo, class: 'BarFoo' do 
  box {'ho'} 
  bex { {foo: :bar } }
end

FakerMaker.factory :green_eggs_and_ham, class: 'Egg' do
  name { Faker::Name.name }
  date { Time.now }
  parameter( has: 2 ) { Faker::Company.bs }
  array( array: true ) { 'bang' }
  sub has: 0..2 do
     FakerMaker.build :Foo
  end
  blank { nil }
end

FakerMaker.factory :seuss, parent: :green_eggs_and_ham do
  quote { 'Today you are you! That is truer than true! There is no one alive who is you-er than you!' }
end

FakerMaker.factory :vehicle do
  wheels { 4 }
  colour { Faker::Color.color_name }
  engine_capacity( json: 'engineCapacity' ) { rand( 600..2500 ) }
end

FakerMaker.factory :motorbike, parent: :vehicle do
  wheels { 2 }
  sidecar { [true, false].sample }
end


FakerMaker.factory :item do
  name( json: 'productName' ) { Faker::Commerce.product_name }
  price( json: 'ticketPrice' ) { Faker::Commerce.price }
end


FakerMaker.factory :basket do
  items( has: 10 ) { FakerMaker[:item].build }
end

FakerMaker.factory :a do
  a( json: 'bigA' ) { 'a' }
end

FakerMaker.factory :b, parent: :a do
  b( json: 'bigB' ) { 'b' }
end

FakerMaker.factory :c, parent: :b do
  c( json: 'bigC' ) { 'c' }
end

FakerMaker.factory :d do
  label{ 'hello' }
end