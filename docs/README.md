<h1 align="center">
  <img src="https://raw.githubusercontent.com/BillyRuffian/faker_maker/master/img/unipug.svg?sanitize=true" alt="Faker Maker" height="150">
</h1>

FakerMaker is a simple data generator with a concise and straightforward syntax.

Sometimes you need generate data; something testers need to do a lot. Often, a bunch of fixtures will be built by hand, carefully maintained and curated, until the API or schema or something changes and all the fixtures need to be pruned before the tests pass again. This drives testers into building fixtures which individually cover lots of acceptance critera just so that they can drive down the number of them they have to maintain until the fixtures don't resemble anything like realistic criteria.



It is designed to resemble the [FactoryBot](https://github.com/thoughtbot/factory_bot) gem but without needing an existing class definition to back its fixtures and so it goes without saying that it offers no persistence mechanism. Its purpose is to provide a simple framework for generating data to test JSON APIs and is intended to be used with the [Faker](https://github.com/stympy/faker) gem (but has no dependency upon it).
