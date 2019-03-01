require 'active_support'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object/json'
require 'faker_maker/version'
require 'faker_maker/base'
require 'faker_maker/factory'
require 'faker_maker/definition_proxy'
require 'faker_maker/attribute'
require 'active_support/core_ext/object/instance_variables'

module FakerMaker
  extend FakerMaker::Base

  class Error < StandardError; end
  # Your code goes here...

  module_function

  def register_factory factory
    factories[factory.name] = factory
  end

  def factories
    @factories ||= {}
  end

  def [] name
    factories[name]
  end

end
