
![CircleCI branch](https://img.shields.io/circleci/project/github/BillyRuffian/faker_maker/master.svg?style=flat-square)
[![CodeFactor](https://www.codefactor.io/repository/github/billyruffian/faker_maker/badge?style=flat-square)](https://www.codefactor.io/repository/github/billyruffian/faker_maker)
![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/BillyRuffian/faker_maker.svg?style=flat-square)

# FakerMaker

FakerMaker is a simple fixture generator with a concise and straightforward syntax.

It is designed to resemble the [FactoryBot](https://github.com/thoughtbot/factory_bot) gem but without needing an existing class definition to back its fixtures and so it goes without saying that it offers no persistence mechanism. Its purpose is to provide a simple framework for generating data to test JSON APIs and is intended to be used with the [Faker](https://github.com/stympy/faker) gem (but has no dependency upon it).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faker_maker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faker_maker

## Usage

FakerMaker generates factories that build disposable objects for testing. Each factory has a name and a set of attributes.

```ruby
FakerMaker.factory :user do 
  name {'Patsy Stone'}
  email {'patsy@fabulous.co.uk'}
  admin {false}
end
```

This will generate a `User` class with the attributes `name`, `email` and `admin` which will always return the same value.

It is possible to explicitly set the name of class which is particularly useful if there is a risk of redefining an existing one.

```ruby
FakerMaker.factory :user, class: 'EmailUser' do 
  name {'Patsy Stone'}
  email {'patsy@fabulous.co.uk'}
  admin {false}
end
```

The class name will always be turned into a Ruby-style class name so `email_user` would become `EmailUser`.

Because of the block syntax in Ruby, defining attributes as `Hash`es requires two sets of curly brackets:

```ruby
FakerMaker.factory :response do 
  body { { title: 'First Post', content: 'This is part of a hash' } }
end
```

### Inheritance

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

### Arrays

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

### Building instances

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

As another convenience, `FakerMaker` is also assign to the variable `FM` to it is possible to write just:

```ruby
result = FM[:basket].build
```

### Embedding factories

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BillyRuffian/faker_maker.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
