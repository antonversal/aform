module Aform
  class Form
    class_attribute :params, :pkey, :validations, :nested_form_klasses

    attr_reader :form_model, :attributes, :nested_forms, :model, :nested_models, :parent

    def initialize(model, attributes, parent = nil, opts = {})
      @opts = opts
      @attributes = attributes
      @model = model
      @parent = parent
      assign_opts_classes(opts)
      initialize_model
      initialize_nested
    end

    def valid?
      if @nested_forms
        main = @form_model.valid?
        #all? don't invoike method on each element
        nested = @nested_forms.values.flatten.map(&:valid?).all?
        main && nested
      else
        @form_model.valid?
      end
    end

    def invalid?
      !valid?
    end

    def save
      self.valid? && @form_saver.new(self).save
    end

    def errors
      @errors_klass.new(self).messages
    end

    class << self
      def primary_key(key)
        self.pkey = key
      end

      def param(*args)
        self.params ||= []
        options = args.extract_options!
        elements = args.map do |a|
          field = {field: a}
          options.present? ? field.merge({options: options}) : field
        end
        self.params += elements
      end

      def method_missing(meth, *args, &block)
        if meth.to_s.start_with?("validate")
          options = {method: meth, options: args}
          options.merge!(block: block) if block_given?
          self.validations ||= []
          self.validations << options
        elsif meth == :has_many
          define_nested_form(args, &block)
        else
          super
        end
      end
    end

    protected

    def self.define_nested_form(args, &block)
      name = args.shift
      self.nested_form_klasses ||= {}
      class_attribute name
      klass = Class.new(Aform::Form, &block)
      self.send("#{name}=", klass)
      self.nested_form_klasses.merge! name => klass
    end

    private

    def assign_opts_classes(opts)
      @model_klass = opts[:model_klass] ||= Aform::Model
      @model_builder = opts[:model_builder] ||= Aform::Builder
      @errors_klass = opts[:errors_klass] ||= Aform::Errors
      @form_saver = opts[:form_saver] ||= Aform::FormSaver
    end

    def initialize_model
      creator = @model_builder.new(@model_klass)
      model_klass = creator.build_model_klass(self.params, self.validations)
      @form_model = model_klass.new(@model, self, @attributes)
    end

    def initialize_nested
      if nested_form_klasses
        nested_form_klasses.each do |k,v|
          if attributes.has_key?(k) && attributes[k]
            attributes[k].each do |attrs|
              @nested_forms ||= {}
              @nested_forms[k] ||= []
              model = nested_ar_model(k, attrs, v.pkey)
              @nested_forms[k] << v.new(model, attrs, self, @opts)
            end
          end
        end
      end
    end

    def nested_ar_model(association, attrs, key)
      key = key || :id
      klass = association.to_s.classify.constantize
      klass.find_by(key => attrs[key]) || klass.new
    end
  end
end
