# frozen_string_literal: true

module FakerMaker
  # Attributes describe the fields of classes
  class Attribute
    attr_reader :name, :block, :translation, :required, :optional, :optional_weighting

    def initialize( name, block = nil, options = {} )
      assert_valid_options options
      @name = name
      @block = block || proc { nil }
      @cardinality = options[:has] || 1
      @translation = options[:json]
      @omit = *options[:omit]
      @array = options[:array] == true

      if options[:required].to_s.downcase.eql?('true')
        @required = true
      else
        @optional = true
        @optional_weighting = [Integer, Float].include?(options[:optional].class) ? options[:optional] : 0.5
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
      options.assert_valid_keys :has, :array, :json, :omit, :required, :optional
    end
  end
end
