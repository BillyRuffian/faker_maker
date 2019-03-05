module FakerMaker
  class Factory
    attr_reader :name, :attributes, :class_name, :parent_class, :parent

    def initialize name, options={}
      assert_valid_options options
      @name = name.respond_to?(:to_sym) ? name.to_sym : name.to_s.underscore.to_sym
      @class_name = (options[:class] || @name).to_s.camelcase
      @attributes = []
      @klass = nil
      @parent = options[:parent]
      @parent_class = if @parent 
        Object.const_get( FakerMaker[@parent].class_name )
      else
         Object
      end
    end

    def attach_attribute attribute 
      @attributes << attribute
    end

    def build
      instance = instantiate
      populate_instance instance
      yield self if block_given?
      instance
    end

    def assemble
      if @klass.nil?
        @klass = Class.new @parent_class
        Object.const_set @class_name, @klass
        attach_attributes_to_class
      end
      @klass
    end

    def to_json
      build.to_json
    end

    def parent?
      ! @parent.nil?
    end

    protected 

    def populate_instance instance
      FakerMaker[parent].populate_instance instance if self.parent?
      @attributes.each do |attr|
        value = nil
        
        if attr.array?
          value = Array.new.tap{ |a| attr.cardinality.times{ a << attr.block.call } }
        else
          value = attr.block.call
        end

        instance.send "#{attr.name}=", value
      end
    end

    private

    def instantiate
      assemble.new
    end

    def attach_attributes_to_class
      @attributes.each do |attr|
        @klass.send( :attr_accessor, attr.name )
      end
    end

    def assert_valid_options options
      options.assert_valid_keys :class, :parent
    end
  end
end