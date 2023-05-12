# frozen_string_literal: true

module FakerMaker
  module LifecycleHooks
    # Lifecycle hooks which can be called during the building of an instance
    module DefinitionProxy
      def before_build
        @factory.define_singleton_method(:before_build) { yield(instance, self) }
      end

      def after_build
        @factory.define_singleton_method(:after_build) { yield(instance, self) }
      end
    end
  end
end
