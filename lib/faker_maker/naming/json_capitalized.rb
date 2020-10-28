# frozen_string_literal: true

module FakerMaker
  module Naming
    module JSONCapitalized
      def self.name(name)
        name.to_s.camelize
      end
    end
  end
end
