# frozen_string_literal: true

module FakerMaker
  # Attributes describe the fields of classes
  class Attribute
    attr_reader :name, :block, :translation, :required, :optional, :optional_weighting, :embedded_factories

    DEFAULT_OPTIONAL_WEIGHTING = 0.5

    def initialize( name, block = nil, options = {} )
      assert_valid_options options
      @name = name
      @block = block || nil
      @cardinality = options[:has] || 1
      @translation = options[:json]
      @omit = *options[:omit]
      @array = options[:array] == true
      @embedded_factories = *options[:factory]

      if options[:required].to_s.downcase.eql?('true') || options[:optional].to_s.downcase.eql?('false')
        @required = true
      else
        @optional = true
        @optional_weighting = determine_optional_weighting(options[:optional])
      end
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

    def omit?( value )
      case value
      when nil
        @omit.include?( :nil ) || @omit.include?( nil )
      when '', [], {}
        @omit.include? :empty
      else
        @omit.include?( :always ) || @omit.include?( value )
      end
    end

    private

    def forced_array?
      @cardinality.is_a?( Range ) || @cardinality > 1
    end

    def assert_valid_options( options )
      options.assert_valid_keys :has, :array, :json, :omit, :required, :optional, :factory
    end

    def determine_optional_weighting( value )
      case value
      when Float
        value.between?(0, 1) ? value : (value / 100)
      when Integer
        value.ceil.between?(0, 100) ? (value.to_f / 100) : DEFAULT_OPTIONAL_WEIGHTING
      else
        DEFAULT_OPTIONAL_WEIGHTING
      end
    end
  end
end
