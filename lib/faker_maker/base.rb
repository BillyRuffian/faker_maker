module FakerMaker
  module Base

    def factory name, options={}, &block
      factory = FakerMaker::Factory.new name, options
      proxy = DefinitionProxy.new factory
      proxy.instance_eval &block if block_given?
      FakerMaker.register_factory factory
    end

    def x_define factory, &block
      proxy = DefinitionProxy.new
      proxy.define factory, &block
      proxy.klass
    end

    def build name
      factory = factories[name]
      raise "No such factory '#{name}'" if factory.nil?
      factory.build
    end
  end
end
