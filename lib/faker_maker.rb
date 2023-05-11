# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object/json'
require 'active_support/core_ext/string'
require 'faker_maker/attribute'
require 'faker_maker/auditable'
require 'faker_maker/base'
require 'faker_maker/configuration'
require 'faker_maker/lifecycle_hooks'
require 'faker_maker/definition_proxy'
require 'faker_maker/factory'

require 'faker_maker/naming'
require 'faker_maker/naming/json'
require 'faker_maker/naming/json_capitalized'
require 'faker_maker/version'

# FakerMaker module for generating Fakes
module FakerMaker
  extend FakerMaker::Base
  extend FakerMaker::Configurable

  class Error < StandardError; end
  class NoSuchFactoryError < StandardError; end
  class NoSuchAttributeError < StandardError; end
  class NoSuchAttributeNamingStrategy < StandardError; end
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
    factory = find_factory(name)
    raise NoSuchFactoryError, "No such factory '#{name}'" unless factory

    factory
  end

  def find_factory( name )
    factories[name]
  end

  def shut!( name )
    factory = find_factory( name )
    return unless factory

    factories[name] = nil
    Object.send( :remove_const, factory.class_name )
  end

  def shut_all!
    factories.each_key { |f| shut!( f ) }
  end
end

FM = FakerMaker
