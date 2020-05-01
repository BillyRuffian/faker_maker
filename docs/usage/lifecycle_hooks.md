---
layout: default
title: Lifecycle Hooks
parent: Usage
nav_order: 8
---

# Lifecycle Hooks

Faker Maker has a few hooks which can be added to the factory which are triggered when the factory builds an instance.

* `before_build` the instance has been created but none of the values have been set yet
* `after_build` the instance has been created and all of the values have been set

For instance:

```ruby
FakerMaker.factory :user do 
  before_build do
    puts 'Building an instance of User'
  end

  name {'Patsy Stone'}
  email {'patsy@fabulous.co.uk'}
  admin {false}
  
  after_build do
    puts "Built an instance of User (#{faker_maker_factory.instance.name})"
  end
end
```

Access to the factory object is through the `faker_maker_factory` method. The instance under construction is available through the `faker_maker_factory.instance` method.