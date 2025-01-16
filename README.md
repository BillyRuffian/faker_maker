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
  [![Downloads](https://img.shields.io/gem/dt/faker_maker)](https://rubygems.org/gems/faker_maker)
  ![CircleCI branch](https://img.shields.io/circleci/project/github/BillyRuffian/faker_maker/master.svg?style=flat-square)
  [![CodeFactor](https://www.codefactor.io/repository/github/billyruffian/faker_maker/badge?style=flat-square)](https://www.codefactor.io/repository/github/billyruffian/faker_maker)
  ![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/BillyRuffian/faker_maker.svg?style=flat-square)

</div>

FakerMaker is a simple factory builder so you can throw away your fixtures and generate test data instead.

Sometimes you need generate data; something testers need to do a lot. Often, a bunch of fixtures will be built by hand, carefully maintained and curated, until the API or schema or something changes and all the fixtures need to be pruned before the tests pass again. This drives testers into building fixtures which individually cover lots of acceptance critera just so that they can drive down the number of them they have to maintain until the fixtures don’t resemble anything like realistic criteria.

If you’re testing a Rails application, you can use the awesome FactoryBot to generate faked model instances but what if you’re not using Rails or you don’t have model classes or you’re testing an API? This is what Faker Maker aims to help with.

It is designed to resemble the Factory Bot gem but without needing an existing class definition to back its object and so it goes without saying that it offers no persistence mechanism. Its purpose is to provide a simple framework for generating data to test JSON APIs and is intended to be used with the Faker gem (but has no dependency upon it).

Read the [documentation here](https://usefakermaker.com).
