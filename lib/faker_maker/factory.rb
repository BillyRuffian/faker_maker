module FakerMaker
  class Factory
    attr_reader :name, :attributes

    def initialize name, options={}
      assert_valid_options options
      @name = name.respond_to?(:to_sym) ? name.to_sym : name.to_s.underscore.to_sym
      @class_name = (options[:class] || @name).to_s.camelcase
      @attributes = []
      @klass = nil
    end

    def attach_attribute attribute 
      @attributes << attribute
    end

    def build
      instance = instantiate
      @attributes.each do |attr|
        value = nil
        
        if attr.is_array?
          value = Array.new.tap{ |a| attr.cardinality.times{ a << attr.block.call } }
        else
          value = attr.block.call
        end

        instance.send "#{attr.name}=", value
      end
      instance
    end

    private

    def instantiate
      assemble_class.new
    end

    def assemble_class
      if @klass.nil?
        @klass = Class.new
        Object.const_set @class_name, klass
        attach_attributes_to_class
      end
      @klass
    end
    alias_method :klass, :assemble_class

    def attach_attributes_to_class
      @attributes.each do |attr|
        @klass.send( :attr_accessor, attr.name )
      end
    end

    def assert_valid_options options
      options.assert_valid_keys :class
    end
  end
end