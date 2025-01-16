---
layout: single
title: Getting started
---

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

Fields with no block (or reference to another factory) will be nil.

```ruby
FakerMaker.factory :request do
  body
end

FakerMaker[:request].build.body
# => nil
```
