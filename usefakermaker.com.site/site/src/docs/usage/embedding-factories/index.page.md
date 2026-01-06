# Embedding Factories

To use factories with factories, the following pattern is recommended:

```ruby
FakerMaker.factory :item do
  name { Faker::Commerce.product_name }
  price { Faker::Commerce.price }
end

FakerMaker.factory :basket do
  items( has: 10, factory: :item )
end
```

In this example, FakerMaker will build an `item` (well, 10 `item`s in this case) using item factory as it is building a `basket`. The advantage of this method is that `item` factory can be declared *after* the `basket` factory.

If you want to select randomly from one or more factories, provide an array of factory names:

```ruby
FakerMaker.factory :coupon do
  discount { Faker::Commerce.price }
end

FakerMaker.factory :item do
  name { Faker::Commerce.product_name }
  price { Faker::Commerce.price }
end

FakerMaker.factory :basket do
  items( has: 10, factory: [:item, :discount] )
end
```

In this example, through 10 iterations, one of `item` and `discount` factories will be called to build their objects.

Blocks can still be provided and the referenced factory built object will be passed to the block:

```ruby
FakerMaker.factory :item do
  name { Faker::Commerce.product_name }
  price { Faker::Commerce.price }
end

FakerMaker.factory :basket do
  items( has: 10, factory: :item ) { |item| item.price = 10.99 ; item}
end
```
**Important:** the value for the attribute will be the value returned from the block. If you want to modify the contents of the referenced factory's object, don't forget to return it at the end of the block (as above).

## Alternative method

There is an alternative style which might be of use:

```ruby
FakerMaker.factory :item do
  name { Faker::Commerce.product_name }
  price { Faker::Commerce.price }
end

FakerMaker.factory :basket do
  items( has: 10 ) { FakerMaker[:item].build }
end
```

With this pattern, you might have to [manage your dependencies](../managing-dependencies/) and `require` your referenced factory.
