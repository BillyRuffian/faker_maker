module FakerMaker
  # Attributes describe the fields of classes
  class Attribute
    attr_reader :name, :block, :translation

    def initialize( name, block = nil, options = {} )
      assert_valid_options options
      @name = name
      @block = block || Proc.new { nil }
      @cardinality = options[:has] || 1
      @translation = options[:json]
      @array = options[:array] == true 
    end

    def array?
      forced_array? || @array
    end

    def cardinality
      if @cardinality.is_a? Range
        rand( @cardinality ) 
      else
        @cardinality
      end
    end

    def translation?
      !@translation.blank?
    end

    private 

    def forced_array?
      @cardinality.is_a?( Range ) || @cardinality > 1
    end

    def assert_valid_options( options )
      options.assert_valid_keys :has, :array, :json
    end
  end
end
