---
layout: single
title: Building Instances
---

Instances are Plain Ol' Ruby Objects and the attributes are attached with getters and setters with their values assigned to the value return from their block at build time.

To build an object:

```ruby
result = FakerMaker[:basket].build
```

will generate a new instance using the Basket factory. Because an actual class is defined, you can instantiate an object directly through `Basket.new` but that will not populate any of the attributes.

It's possible to override attributes at build-time, either by passing values as a hash:

```ruby
result = FakerMaker[:item].build( name: 'Electric Blanket' )
```

or by passing in a block:

```ruby
result = FakerMaker[:item].build{ |i| i.name = 'Electric Sheep' }
```

this is particularly useful for overriding nested values, since all the getters and setters of the embedded objects are already constructed:

```ruby
result = FakerMaker[:basket].build do |b|
  b.items.first.name = 'Neon Badger'
end
```

if you're crazy enough to want to do both styles during creation, the values in the block will be preserved, e.g.

```ruby
result = FakerMaker[:item].build( name: 'Electric Blanket' ) do |i|
  i.name = 'Electric Sheep'
end
```

then the value of `result.name` is 'Electric Sheep'.

Beware when overriding values in this way: there is no type checking. You will get an exception if you try to set a value to an attribute that doesn't exist but you won't get one if you assign, say, an array of values where you would otherwise have a string and vice versa.

Calling `result.to_json` will give a stringified JSON representation. Because ActiveSupport is used under the covers, `as_json` will give you a `Hash` rather than the stringified version.

As a convenience, you can request a JSON representation directly:

```ruby
result = FakerMaker[:basket].to_json
```

As another convenience, `FakerMaker` is also assigned to the variable `FM` to it is possible to write just:

```ruby
result = FM[:basket].build
```
