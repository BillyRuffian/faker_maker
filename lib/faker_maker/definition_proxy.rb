module FakerMaker
  class DefinitionProxy

    def initialize factory
      @factory = factory
    end

    def method_missing name, *args, &block
      attribute = FakerMaker::Attribute.new name, *args, block
      @factory.attach_attribute attribute
    end

  end
end