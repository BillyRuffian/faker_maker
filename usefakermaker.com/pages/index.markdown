---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

# layout: single
layout: splash
permalink: /
author_profile: false

feature_row:
  - image_path: /assets/images/unipug.svg
    alt: An illustration of cute pug dog pretending to be a unicorn by wearing a costume
    title: Factories over fixtures
    excerpt: FakerMaker is a simple factory builder so you can throw away your fixtures and generate test data instead.
    url: "/docs/installing/"
    btn_label: "Get Started"
    btn_class: "btn btn--success"
---

{% include feature_row type="center" %}

Sometimes you need generate data; something testers need to do a lot. Often, a bunch of fixtures will be built by hand, carefully maintained and curated, until the API or schema or something changes and all the fixtures need to be pruned before the tests pass again. This drives testers into building fixtures which individually cover lots of acceptance critera just so that they can drive down the number of them they have to maintain until the fixtures don’t resemble anything like realistic criteria.

If you’re testing a Rails application, you can use the awesome FactoryBot to generate faked model instances but what if you’re not using Rails or you don’t have model classes or you’re testing an API? This is what Faker Maker aims to help with.

It is designed to resemble the Factory Bot gem but without needing an existing class definition to back its object and so it goes without saying that it offers no persistence mechanism. Its purpose is to provide a simple framework for generating data to test JSON APIs and is intended to be used with the Faker gem (but has no dependency upon it).

