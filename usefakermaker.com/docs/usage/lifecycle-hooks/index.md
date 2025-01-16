---
layout: single
title: Lifecycle Hooks
---

Faker Maker has a few hooks which can be added to the factory which are triggered when the factory builds an instance.

* `before_build` the instance has been created but none of the values have been set yet
* `after_build` the instance has been created and all of the values have been set

For instance:

```ruby
FakerMaker.factory :user do
  before_build do |instance, factory|
    puts 'Building an instance of User'
  end

  name {'Patsy Stone'}
  email {'patsy@fabulous.co.uk'}
  admin {false}

  after_build do |instance, factory|
    puts "Built an instance of User (#{instance.name})"
  end
end
```
