---
layout: default
title: Arrays
parent: Usage
nav_order: 2
---

# Arrays

It is possible to declare an attribute as having multiple values.

```ruby
FakerMaker.factory :basket do
  items( has: 10 ) { Faker::Commerce.product_name }
end
```

or to pick random number of attributes from a range:

```ruby
FakerMaker.factory :basket do
  items( has: 5..20 ) { Faker::Commerce.product_name }
end
```

A range always generates an array, even if the range produces 1 items or the range is `0..1`.

It is possible to force an attribute to always be an array, even if only produces one item.

```ruby
FakerMaker.factory :basket do
  items( array: true ) { Faker::Commerce.product_name }
end
```

You can always use long-form block syntax...

```ruby
FakerMaker.factory :basket do
  items has: 5..20 do
    Faker::Commerce.product_name
  end
end
```