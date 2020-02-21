---
layout: default
title: Destroying Factories
parent: Usage
nav_order: 8
---

# Destroying Factories

Faker Maker deliberately does not allow you to redefine a factory by redeclaring it. It will also be silent about your attempt to do so. This is to avoid throwing up runtime warning from the Ruby interpreter if you are embedding one factory definition in another.

For example, this might give you unexpected behavior:

```ruby
FakerMaker.factory :user do 
  name {'Patsy Stone'}
end

FakerMaker.factory :user do 
  name {'Patsy Stone'}
  email {'patsy@fabulous.co.uk'}
end

FM[:user].as_json
 => {:name=>"Patsy Stone"}
```

On the other hand, sometimes you really, really want to destroy a factory and start again (especially if you are experimenting in a REPL for example). FakerMaker allows you to shut a factory which will de-register it from the list of available factories and attempt to unload the class it has built from the Ruby interpreter.

```ruby
FakerMaker.factory :user do 
  name {'Patsy Stone'}
end

FakerMaker.shut!(:user)

FakerMaker.factory :user do 
  name {'Patsy Stone'}
  email {'patsy@fabulous.co.uk'}
end

FM[:user].as_json
 => {:name=>"Patsy Stone", :email=>"patsy@fabulous.co.uk"}
 ```
 
 It also provides the `shut_all!` method to remove all factories.