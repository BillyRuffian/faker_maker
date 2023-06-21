---
layout: default
title: Chaos
parent: Usage
nav_order: 11
---

# Chaos

Chaos mode introduces extra spice to your generated factories. 

Attributes can be marked as either `required` or `optional`, which Chaos will use to determine what attributes are included when instantiating your factory. 

Required attributes will always be present, however, optional attributes are not guaranteed to be present when Chaos is enabled. 

*All attributes are optional by default.*

To explicitly mark attributes as either required or optional:

```ruby
FM.factory :item, naming: :json do
  name { 'Blanket' }
  price(required: true) { 100 }
  description(optional: true) { 'Keeps you warm and cozy' }
  manufacturer(optional: 0.7) { 'A large fruit company' }
end
```

You can state an attribute is optional using the `optional` option set to either be a `Boolean`, `Integer` or a `Float`. 

When optional is set to either an `Integer` or a `Float`, this overrides the weighting which Chaos uses to determine the likelihood that attribute will be removed.

Higher the value, the more likely that attribute will be present. By default there's a 50/50 chance an optional attribute will be present. 

To unleash Chaos over a factory, you need to enable it when instantiating your object:

```ruby
result = FakerMaker[:item].build( chaos: true )
```

You can also specify which attributes Chaos can use when instantiating your object:

```ruby
result = FakerMaker[:item].build( chaos: %i[name manufacturer] )
```
