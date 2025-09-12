# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module FakerMaker
  # Factories construct instances of a fake
  class Factory
    include Auditable

    attr_reader :name, :class_name, :parent, :chaos_selected_attributes

    # Create a new +Factory+ object.
    #
    # This method does not automatically register the factory,see
    # FakerMaker#register_factory
    #
    # Options:
    # - +:class_name+ - override the default class name that FakerMaker will generate.
    #   This is useful in the case of collisions with existing classes or keywords.
    # - +:parent+ - the parent factory from which this factory inherits attributes.
    #   Instances built by this factory will have a class which inherits from the parent's
    #   class.
    # - +:naming+ - one of:
    #   - +nil+ (default) - use field names as the method name and in JSON conversion
    #   - +:json+ - use field names as the method name but convert when rendering JSON, e.g.
    #     +hello_world+ becomes +helloWorld+
    #   - +:json_capitalised+ (or +:json_capitalized+) - as +:json+ but with the first letter
    #     captialised, e.g. +hello_world+ becomes +HelloWorld+
    def initialize( name, options = {} )
      assert_valid_options options
      @name = name.respond_to?(:to_sym) ? name.to_sym : name.to_s.underscore.to_sym
      @class_name = (options[:class] || @name).to_s.camelcase
      @naming_strategy = case options[:naming]
                         when :json
                           FakerMaker::Naming::JSON
                         when :json_capitalized, :json_capitalised
                           FakerMaker::Naming::JSONCapitalized
                         when nil
                           nil
                         else
                           raise FakerMaker::NoSuchAttributeNamingStrategy, options[:naming]
                         end
      @attributes = []
      @klass = nil
      @parent = options[:parent]
    end

    # Get the Class of the parent for this factory
    def parent_class
      if @parent
        FakerMaker::Factory.const_get( FakerMaker[@parent].class_name )
      else
        Object
      end
    end

    # Attach a FakerMaker::Attribute to this Factory
    def attach_attribute( attribute )
      @attributes << attribute
    end

    def instance
      @instance ||= instantiate
    end

    def build( attributes: {}, chaos: false, **kwargs )
      # TODO: deprecation -- remove the option of the old style way of building
      if kwargs.present?
        validate_deprecated_build(kwargs)
        attributes = kwargs
      end

      @instance = nil
      before_build if respond_to? :before_build

      # TODO: make this cleverer to handle nested attributes
      # assert_only_known_attributes_for_override( attributes )

      # TODO: revisit this method -- what about chaos on nested attrs?????
      assert_chaos_options chaos if chaos

      optional_attributes
      required_attributes

      populate_instance(instance, attributes, chaos)
      yield instance if block_given?

      after_build if respond_to? :after_build
      audit(@instance) if FakerMaker.configuration.audit?
      instance
    end

    # Construct a Class object which will become the parent type of objects built
    # by this factory.
    #
    # The Class object will be created and the attributes added to it. The returned value
    # is a Ruby Class which can be instantiated.
    def assemble
      if @klass.nil?
        @klass = Class.new parent_class
        FakerMaker::Factory.const_set @class_name, @klass
        attach_attributes_to_class
        attach_json_overrides_to_class
      end
      @klass
    end

    def to_json(*_args)
      build.to_json
    end

    def as_json(*_args)
      build.as_json
    end
    alias to_h as_json

    def parent?
      !@parent.nil?
    end

    def json_key_map
      unless @json_key_map
        @json_key_map = {}.with_indifferent_access
        @json_key_map.merge!( FakerMaker[parent].json_key_map ) if parent?
        attributes(include_embeddings: false).each_with_object( @json_key_map ) do |attr, map|
          key = if attr.translation?
                  attr.translation
                elsif @naming_strategy
                  @naming_strategy.name(attr.name)
                else
                  attr.name
                end

          map[attr.name] = key
        end
      end
      @json_key_map
    end

    ## Recursively transforms attributes to names, handling nested hashes.
    def attribute_names
      transform = lambda do |arr|
        arr.map do |item|
          if item.is_a?(Hash)
            item.transform_keys(&:name).transform_values { |v| transform.call(v) }
          else
            item.name
          end
        end
      end
      transform.call(attributes)
    end

    ## embedded factories, if plural, does not imply they are instantiated
    def attributes( collection = [], include_embeddings: true )
      collection |= FakerMaker[parent].attributes( collection ) if parent?
      collection |= @attributes.reject { |attr| attr.embedded_factories.any? }

      # if there is an embedded factory(-ies) and we are including the embedded factory's
      # fields, we are going to return a hash
      if include_embeddings
        @attributes.select { |attr| attr.embedded_factories.any? }.each do |attr|
          collection << { attr => attr.embedded_factories.flat_map(&:attributes) }
        end
      # if there is an embedded factory(-ies) and we are not including the embedded factory's
      # fields, just add the attribute into the set of returned fields
      else
        collection |= @attributes.select { |attr| attr.embedded_factories.any? }
      end

      collection
    end

    def find_attribute( name = '' )
      attributes(include_embeddings: false).filter { |a| [a.name, a.translation, @naming_strategy&.name(a.name)].include? name }.first
    end

    protected

    def populate_instance( instance, attr_override_values, chaos )
      FakerMaker[parent].populate_instance instance, attr_override_values, chaos if parent?

      attributes = chaos ? chaos_select(chaos) : @attributes

      attributes.each do |attribute|
        value = value_for_attribute( instance, attribute, attr_override_values )
        instance.send "#{attribute.name}=", value
      end
      instance.instance_variable_set( :@fm_factory, self )
    end

    private

    def assert_only_known_attributes_for_override( attr_override_values )
      unknown_attrs = attr_override_values.keys - attribute_names
      issue = "Can't build an instance of '#{class_name}' " \
              "setting '#{unknown_attrs.join( ', ' )}', no such attribute(s)"
      raise FakerMaker::NoSuchAttributeError, issue unless unknown_attrs.empty?
    end

    def assert_only_known_and_optional_attributes_for_chaos( chaos_attr_values )
      chaos_attr_values = chaos_attr_values.map(&:to_sym)
      unknown_attrs = chaos_attr_values - attribute_names
      issue = "Can't build an instance of '#{class_name}' " \
              "setting '#{unknown_attrs.join( ', ' )}', no such attribute(s)"
      raise FakerMaker::NoSuchAttributeError, issue unless unknown_attrs.empty?

      # Are any chaos attributes marked as required?
      conflicting_attributes = chaos_attr_values.select { |attr| required_attributes.map(&:name).include? attr }
      issue = "Can't use chaos on a required attribute: '#{conflicting_attributes}'"
      raise FakerMaker::ChaosConflictingAttributeError, issue unless conflicting_attributes.empty?
    end

    def overridden_value?( attr, attr_override_values )
      attr_override_values.keys.include?( attr.name )
    end

    def value_for_attribute( instance, attr, attr_override_values )
      if !attr.embedded_factories? && overridden_value?( attr, attr_override_values )
        attr_override_values[attr.name]
      elsif attr.array?
        [].tap do |a|
          attr.cardinality.times do
            manufacture = manufacture_from_embedded_factory( attr, attr_override_values[attr.name.to_sym] )
            # if manufacture has been build and there is a block, instance_exec the block
            # otherwise just add the manufacture to the array
            a << (attr.block ? instance.instance_exec(manufacture, &attr.block) : manufacture)
          end
        end
      else
        manufacture = manufacture_from_embedded_factory( attr, attr_override_values[attr.name.to_sym] )
        attr.block ? instance.instance_exec(manufacture, &attr.block) : manufacture
      end
    end

    def manufacture_from_embedded_factory( attr, attributes = {} )
      attributes ||= {}
      # The name of the embedded factory randomly selected from the list of embedded factories.
      embedded_factory = attr.embedded_factories.sample
      # The object that is being manufactured by the factory.
      # If an embedded factory name is provided, it builds the object using FakerMaker.
      embedded_factory&.build(attributes:)
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
        super( options.merge( except: 'fm_factory' ) )
          .transform_keys { |key| @fm_factory.json_key_map[key] || key }
          .filter { |key, value| !@fm_factory.find_attribute(key)&.omit?( value ) }
      end
      @klass.alias_method :to_h, :as_json
    end

    def assert_valid_options( options )
      options.assert_valid_keys :class, :parent, :naming
    end

    # Asserts attributes passed in for chaos mode are valid
    def assert_chaos_options( chaos )
      eval = -> { [Array, String, TrueClass, FalseClass, Symbol].include? chaos.class }
      msg = "chaos: arg does not support object of type: '#{chaos.class}'"
      raise NoSuchAttributeError, msg unless eval.call

      case chaos
      when Array
        assert_only_known_and_optional_attributes_for_chaos(chaos)
      when String, Symbol
        assert_only_known_and_optional_attributes_for_chaos([chaos])
      end
    end

    # Selects required @attributes
    def required_attributes
      @required_attributes ||= @attributes.select { |attr| attr.required.eql? true }
    end

    # Selects optional @attributes
    def optional_attributes
      @optional_attributes ||= @attributes.select(&:optional)
    end

    # Randomly selects optional attributes
    # Attributes selected from parent will also be selected for the child
    # @param [Array || TrueClass] chaos_attrs
    # @return [Array]
    def chaos_select( chaos_attrs = [] )
      selected_attrs = []
      optional_attrs = optional_attributes.dup

      # Filter specific optional attributes if present
      if chaos_attrs.is_a?(Array) && chaos_attrs.size.positive?
        optional_attrs, selected_attrs = optional_attrs.partition { |attr| chaos_attrs.include?(attr.name) }
      end

      # Grab parent selected attributes
      @chaos_selected_attributes = parent? ? FakerMaker[parent].chaos_selected_attributes : []
      selected_inherited_attr = optional_attrs.select do |attr|
        @chaos_selected_attributes.map(&:name).include? attr.name
      end

      # Select optional attributes based on weighting
      optional_attrs.each do |optional_attr|
        selected_attrs.push(optional_attr) if Random.rand < optional_attr.optional_weighting
      end

      # Concat required, selected and parent attributes
      @chaos_selected_attributes.concat(required_attributes)
                                .concat(selected_inherited_attr)
                                .concat(selected_attrs).uniq!
      @chaos_selected_attributes
    end

    def validate_deprecated_build(kwargs)
      usage = kwargs.each_with_object([]) { |kwarg, result| result << "#{kwarg.first}: #{kwarg.last}" }.join(', ')

      warn "[DEPRECATION] `FM[:#{name}].build(#{usage})` is deprecated. " \
           "Please use `FM[:#{name}].build(attributes: { #{usage} })` instead."
    end
  end
end
# rubocop:enable Metrics/ClassLength
