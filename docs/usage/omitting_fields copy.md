---
layout: default
title: Omitting Fields
parent: Usage
nav_order: 5
---

# Omitting Fields

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