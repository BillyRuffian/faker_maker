# frozen_string_literal: true

module FakerMaker
  module LifecycleHooks
    module DefinitionProxy
    
      def before_build(&block)
        @factory.define_singleton_method(:before_build) { block.call}
      end
      
      def after_build(&block)
        @factory.define_singleton_method(:after_build) { block.call}
      end
    
    end
  end
end