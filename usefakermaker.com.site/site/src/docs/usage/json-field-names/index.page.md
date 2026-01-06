# JSON Field Names

JavaScript likes to use camelCase, Ruby's idiom is to use snake_case. This can make make manipulating factory-built objects in ruby ugly. To avoid this, you can call your fields one thing and ask the JSON outputter to rename the field when generating JSON.

Faker Maker provides two mechanisms for dealing with this.

## Factory-wide attribute name re-writing (since 1.1.10)

Using the `:naming` option to the factory, you can specify a naming strategy. Currently supported are:

* `:json` camelCase with lowercase first letter
* `:json_capitalized` CamelCase with uppercase first letter

```ruby
FakerMaker.factory :vehicle, naming: :json do
  wheels { 4 }
  colour { Faker::Color.color_name }
  engine_capacity { rand( 600..2500 ) }
end

v = FM[:vehicle].build
v.engine_capacity = 125

v.to_json

=> "{\"wheels\":4,\"colour\":\"blue\",\"engineCapacity\":125}"
```

## Per-attribute naming

You can override the name of the attribute on the individual attribute level.

```ruby
FakerMaker.factory :vehicle do
  wheels { 4 }
  colour { Faker::Color.color_name }
  engine_capacity(json: 'engineCapacity') { rand( 600..2500 ) }
end

v = FM[:vehicle].build
v.engine_capacity = 125

v.to_json

=> "{\"wheels\":4,\"colour\":\"blue\",\"engineCapacity\":125}"
```

## Combining the two approaches

If the factory has a `:naming` strategy defined and an attribute has its own `:json` name defined, the attribute's `:json` name will take precedence.
