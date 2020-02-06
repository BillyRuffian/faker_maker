---
layout: default
title: Inheritance
parent: Usage
nav_order: 1
---

# Inheritance

FakerMaker can exploit the Ruby class hierarchy to provide additional specialisation or to override some behaviours:

```ruby
FakerMaker.factory :vehicle do
  wheels { 4 }
  colour { Faker::Color.color_name }
  engine_capacity { rand( 600..2500 ) }
end

FakerMaker.factory :motorbike, parent: :vehicle do
  wheels { 2 }
  sidecar { [true, false].sample }
end
```

This is the equivalent of: 

```ruby
class Vehicle < Object
  # ...
end

class Motorbike < Vehicle
  # ...
end
```

so a motorbike will still have a colour and engine capacity between 600 and 2500.