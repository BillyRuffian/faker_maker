require 'faker_maker'
require 'awesome_print'

FM.factory :random do
  flavour { 'blue' }
end

FM.factory :item do
  name { 'toothpaste' }
  price { 0.99 }
end

FM.factory :coupon do
  discount { 0.10 }
end

FM.factory :basket do
  items( factory: %i[item random] )
end

# { a: 1, b: { x: 2 } }
