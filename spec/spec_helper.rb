# frozen_string_literal: true

require 'simplecov'
require 'coveralls'
Coveralls.wear!

SimpleCov.start do
  add_filter '/spec/'
end

require 'bundler/setup'
require 'faker_maker'
require 'faker'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:each) do
    FakerMaker.shut_all!
  end
end
