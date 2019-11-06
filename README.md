<h1 align="center">
  <img src="https://raw.githubusercontent.com/BillyRuffian/faker_maker/master/img/unipug.svg?sanitize=true" alt="Faker Maker" height="200">
  <br>
  Faker Maker
  <br>
</h1>

<h4 align="center">
  Factories over Fixtures
</h4>

<div align="center">

  [![Gem Version](https://badge.fury.io/rb/faker_maker.svg)](https://badge.fury.io/rb/faker_maker)
  ![CircleCI branch](https://img.shields.io/circleci/project/github/BillyRuffian/faker_maker/master.svg?style=flat-square)
  [![CodeFactor](https://www.codefactor.io/repository/github/billyruffian/faker_maker/badge?style=flat-square)](https://www.codefactor.io/repository/github/billyruffian/faker_maker)
  ![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/BillyRuffian/faker_maker.svg?style=flat-square)

</div>

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

Blocks are executed in the context of their instance. This means you can refer to variables already defined:

```ruby
FakerMaker.factory :user, class: 'EmailUser' do 
  title {'Ms'}
  name {'Patsy Stone'}
  formal_name {"#{title} #{name}"}
  email {'patsy@fabulous.co.uk'}
  admin {false}
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

### Organising dependencies

Factory definition files are Plain Ol' Ruby. If you depend on another factory because you either extend from it or use it just add a `require` or (depending on your load path) `require_relative` to the top of your file. 

### JSON field names

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

### Omitting fields

Sometimes you want a field present, other times you don't. This is often the case when you want to skip fields which have null or empty values.

```ruby
FakerMaker.factory :user do 
  name {'Patsy Stone'}
  email(omit: :nil) {'patsy@fabulous.co.uk'}
  admin {false}
end

FM[:user].build.as_json
=> {:name=>"Patsy Stone", :email=>"patsy@fabulous.co.uk", :admin=>false}

FM[:user].build(email: nil).as_json
=> {:name=>"Patsy Stone", :admin=>false}
```

The `omit` modifier can take a single value or an array. If it is passed a value and the attribute equals this value, it will not be included in the output from `as_json` (which returns a Ruby Hash) or in `to_json` methods.

There are three special modifiers:

* `:nil` (symbol) to omit output when the attribute is set to nil
* `:empty` to omit output when the value is an empty string, an empty array or an empty hash
* `:always` to never output this attribute.

These can be mixed with real values, e.g.

```ruby
FakerMaker.factory :user do 
  name {'Patsy Stone'}
  email(omit: [:nil, :empty, 'test@foobar.com']) {'patsy@fabulous.co.uk'}
  admin {false}
end
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

## Extra credit

Unipug logo by <a href="https://pixabay.com/users/1smr1-4646356/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=2970825">1smr1</a> from <a href="https://pixabay.com/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=2970825">Pixabay</a>