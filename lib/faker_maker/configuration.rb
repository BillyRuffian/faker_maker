module FakerMaker

  # Configuration class, holds all the config options for FM
  class Configuration
    attr_writer :audit
    attr_accessor :audit_destination

    def initialize
      @audit = false
      @audit_destination = $stdout
    end

    def audit?
      @audit
    end
  end

  # Mixin to provide configuraton methods to an extending or implementing class
  module Configurable
    
    def configuration
      @configuration ||= Configuration.new
    end

    def configuration=(config)
      @configuration = config
    end

    def configure
      yield(configuration) if block_given?
    end

  end
end