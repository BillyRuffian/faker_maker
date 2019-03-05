module FakerMaker
  module Base

    def factory name, options={}, &block
      factory = FakerMaker::Factory.new name, options
      proxy = DefinitionProxy.new factory
      proxy.instance_eval &block if block_given?
      FakerMaker.register_factory factory
    end
    
  end
end
