module FakerMaker
  # Factories construct instances of a fake
  class Factory
    attr_reader :name, :attributes, :class_name, :parent_class, :parent

    def initialize( name, options = {} )
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

    def attach_attribute( attribute )
      @attributes << attribute 
    end

    def build( attributes={} )
      instance = instantiate
      populate_instance instance, attributes
      yield instance if block_given?
      instance
    end

    def assemble
      if @klass.nil?
        @klass = Class.new @parent_class
        Object.const_set @class_name, @klass
        attach_attributes_to_class
        attach_json_overrides_to_class
      end
      @klass
    end

    def to_json
      build.to_json
    end

    def parent?
      ! @parent.nil?
    end

    def json_key_map
      unless @json_key_map
        @json_key_map = {}.with_indifferent_access
        @json_key_map.merge!( FakerMaker[parent].json_key_map ) if parent?
        attributes.each_with_object( @json_key_map ) do |attr, map|
          key = attr.translation? ? attr.translation : attr.name
          map[attr.name] = key
        end
      end
      @json_key_map
    end

    protected 

    def populate_instance( instance, attr_override_values )
      assert_only_know_attributes_for_override( attr_override_values )
    
      FakerMaker[parent].populate_instance instance if parent?
      @attributes.each do |attr|       
        value = value_for_attribute( attr, attr_override_values )
        instance.send "#{attr.name}=", value
      end
      instance.instance_variable_set( :@fm_factory, self )
    end

    private
    
    def assert_only_know_attributes_for_override( attr_override_values )
      unknown_attrs = attr_override_values.keys - @attributes.map( &:name )
      issue = "Can't build an instance of '#{class_name}' " \
              "setting '#{unknown_attrs.join( ', ' )}', no such attribute(s)"
      raise FakerMaker::NoSuchAttributeError, issue unless unknown_attrs.empty?
    end
    
    def attribute_hash_overridden_value?( attr, attr_override_values )
      !attr_override_values[attr.name].nil?
    end
    
    def value_for_attribute( attr, attr_override_values )
      if attribute_hash_overridden_value?( attr, attr_override_values )
        attr_override_values[attr.name]
      elsif attr.array?
        [].tap { |a| attr.cardinality.times { a << attr.block.call } }
      else
        attr.block.call
      end
    end

    def instantiate
      assemble.new
    end

    def attach_attributes_to_class
      @attributes.each do |attr|
        @klass.send( :attr_accessor, attr.name )
      end
      @klass.send( :attr_reader, :fm_factory )
    end

    def attach_json_overrides_to_class
      @klass.define_method :as_json do |options = {}|
        super( options.merge( except: 'fm_factory' ) ).transform_keys { |key| @fm_factory.json_key_map[key] || key }
      end
    end

    def assert_valid_options( options )
      options.assert_valid_keys :class, :parent
    end
  end
end
