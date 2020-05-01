---
layout: default
title: Embedding Factories
parent: Usage
nav_order: 8
---

# Embedding Factories

To use factories with factories, the following pattern is recommended:

```ruby
FakerMaker.factory :item do
  name { Faker::Commerce.product_name }
  price { Faker::Commerce.price }
end

FakerMaker.factory :basket do
  items( has: 10 ) { FakerMaker[:item].build }
end
```

You might have to [manage your dependencies]({% link usage/dependencies.md %}) and `require` your referenced factory.