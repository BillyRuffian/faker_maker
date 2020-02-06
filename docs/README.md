---
layout: default
title: Home
nav_order: 1
permalink: /
---

# Factories over fixtures
{: .fs-9 }

FakerMaker is a simple data generator with a concise and straightforward syntax so you can throw away your fixtures and generate test data instead.
{: .fs-6 .fw-300 }

Sometimes you need generate data; something testers need to do a lot. Often, a bunch of fixtures will be built by hand, carefully maintained and curated, until the API or schema or something changes and all the fixtures need to be pruned before the tests pass again. This drives testers into building fixtures which individually cover lots of acceptance critera just so that they can drive down the number of them they have to maintain until the fixtures don't resemble anything like realistic criteria.

If you're testing a Rails application, you can use the awesome [FactoryBot](https://github.com/thoughtbot/factory_bot) to generate faked model instances but what if you're not using Rails or you don't have model classes or you're testing an API? This is what Faker Maker aims to help with.

It is designed to resemble the Factory Bot gem but without needing an existing class definition to back its object and so it goes without saying that it offers no persistence mechanism. Its purpose is to provide a simple framework for generating data to test JSON APIs and is intended to be used with the [Faker](https://github.com/stympy/faker) gem (but has no dependency upon it).
