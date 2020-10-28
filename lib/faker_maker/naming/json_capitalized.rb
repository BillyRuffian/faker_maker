# frozen_string_literal: true

module FakerMaker
  module Naming
    # Use CamelCase for naming
    module JSONCapitalized
      def self.name(name)
        name.to_s.camelize
      end
    end
  end
end
