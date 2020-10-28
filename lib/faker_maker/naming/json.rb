# frozen_string_literal: true

module FakerMaker
  module Naming
    # Use camelCase for naming
    module JSON
      def self.name(name)
        name.to_s.camelize(:lower)
      end
    end
  end
end
