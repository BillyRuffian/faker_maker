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
  items( has: 10, factory: [:item, :coupon] ) # either `item` or `coupon` will be randomly selected for each member
end
```

In this example, through 10 iterations, a random choice of `item` and `discount` factories will be called to build their objects.

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

## Overriding values for nested factories in the enclosing factory

**Important:** the value for the attribute will be the value returned from the block. If you want to modify the contents of the referenced factory's object, don't forget to return it at the end of the block (as above).

## Overriding values for nested factories during build

If we look carefully at this factory

```ruby
FakerMaker.factory :inventory do
  item( factory: :item )
  quantity { 10 }
end
```

This will build a object of the form (in its `as_json` guise):

```ruby
{item: {name: "toothpaste", price: 0.99}, quantity: 10}
```

When it comes to overriding values at build time, a hash can be passed to set the nested values:

```ruby
FM[:inventory].build( attributes: { item: { name: 'floor cleaner' } } )
```

There is **one exception** to this. Passing in an empty Hash will always set the attribute to an empty Hash. This is by-design to support the testing of invalid message formats with JSON APIs.

When you allow Faker Maker to make a choice of factory by giving it an array:

```ruby
FakerMaker.factory :inventory do
  item( factory: [:item, :coupon] )
  quantity { 10 }
end
```

...either the `item` or `coupon` fields could be added to each build of the `inventory` factory.

**Since v5.0.3** when passing override values to `#build` and where the factory has a choice of embedded factory, as in the example above where an inventory may contain either an item or a coupon, Faker Maker will attempt to locate the embedded factory which most matches the values give in the override. For example, if the attributes given to build the `item` field most match `coupon` fields, that embedded factory will be chosen. If there are still several choices which match the given attributes, a random selection will be made.

## Alternative method

There is an alternative style which might be of use, **but** you have less control using build-time overrides for values (you can't set nested values). *This is no longer a recommended pattern*.

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
