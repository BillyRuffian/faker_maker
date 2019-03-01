module FakerMaker
  class Attribute
    attr_reader :name, :block

    def initialize name, options={}, block
      assert_valid_options options
      @name = name
      @block = block
      @cardinality = options[:has] || 1
      @array = options[:array] == true 
    end

    def is_array?
      is_forced_array? || @array
    end

    def cardinality
      if @cardinality.is_a? Range
        rand( @cardinality ) 
      else
        @cardinality
      end
    end

    private 

    def is_forced_array?
      @cardinality.is_a?( Range ) || @cardinality > 1
    end

    def assert_valid_options options
      options.assert_valid_keys :has, :array
    end

  end
end