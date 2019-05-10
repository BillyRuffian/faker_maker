module FakerMaker
  # Proxy for mapping attribute names
  class DefinitionProxy
    def initialize(factory)
      @factory = factory
    end

    def method_missing(name, *args, &block)
      attribute = FakerMaker::Attribute.new name, block, *args
      @factory.attach_attribute attribute
      super
    end
    
    def respond_to_missing?(method_name, include_private = false)
      super
    end
  end
end
