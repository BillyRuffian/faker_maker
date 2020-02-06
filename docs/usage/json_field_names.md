---
layout: default
title: JSON Field Names
parent: Usage
nav_order: 4
---

# JSON field names

JavaScript likes to use camelCase, Ruby's idiom is to use snake_case. This can make make manipulating factory-built objects in ruby ugly. To avoid this, you can call your fields one thing and ask the JSON outputter to rename the field when generating JSON.

```ruby
FakerMaker.factory :vehicle do
  wheels { 4 }
  colour { Faker::Color.color_name }
  engine_capacity(json: 'engineCapacity') { rand( 600..2500 ) }
end

v = FM[:vehicle].build
v.engine_capacity = 125
```

and calls to `as_json` and `to_json` will report the fieldname as `engineCapacity`.

```ruby
v.to_json

=> "{\"wheels\":4,\"colour\":\"blue\",\"engineCapacity\":125}"
```