# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object/json'
require 'faker_maker/version'
require 'faker_maker/base'
require 'faker_maker/factory'
require 'faker_maker/definition_proxy'
require 'faker_maker/attribute'

# FakerMaker module for generating Fakes
module FakerMaker
  extend FakerMaker::Base

  class Error < StandardError; end
  class NoSuchFactoryError < StandardError; end
  class NoSuchAttributeError < StandardError; end
  # Your code goes here...

  module_function

  def register_factory( factory )
    factory.assemble
    factories[factory.name] = factory
  end

  def factories
    @factories ||= {}
  end

  def build( name )
    find_factory( name ).build
  end

  def []( name )
    find_factory name
  end
  
  def find_factory( name )
    raise NoSuchFactoryError, "No such factory '#{name}'" if factories[name].nil?
    
    factories[name]
  end
end

FM = FakerMaker
