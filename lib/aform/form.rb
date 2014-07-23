module Aform
  class Form
    class_attribute :params, :pkey, :validations, :nested_form_klasses

    attr_reader :form_model, :attributes, :nested_forms, :model, :nested_models, :parent

    def initialize(model, attributes, parent = nil, model_klass = Aform::Model,
      model_builder = Aform::Builder, errors_klass = Aform::Errors,
      form_saver = Aform::FormSaver)
      @model_klass, @model_builder, @errors_klass = model_klass, model_builder, errors_klass
      @model, @attributes = model, attributes
      @parent = parent
      @form_saver = form_saver
      creator = @model_builder.new(@model_klass)
      @form_model = creator.build_model_klass(self.params, self.validations).new(@model, self, @attributes)
      initialize_nested
    end

    def invalid?
      !valid?
    end

    def valid?
      if @nested_forms
        main = @form_model.valid?
        nested = @nested_forms.values.flatten.map(&:valid?).all? #all? don't invoike method on each element
        main && nested
      else
        @form_model.valid?
      end
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

    def initialize_nested
      if nested_form_klasses
        nested_form_klasses.each do |k,v|
          if attributes.has_key?(k) && attributes[k]
            attributes[k].each do |attrs|
              @nested_forms ||= {}
              @nested_forms[k] ||= []
              model = nested_ar_model(k, attrs, v.pkey)
              @nested_forms[k] << v.new(model, attrs, self, @model_klass, @model_builder,
                                        @errors_klass, @form_saver)
            end
          end
        end
      end
    end

    def nested_ar_model(association, attrs, key = :id)
      key = key || :id
      klass = association.to_s.classify.constantize
      klass.find_by(key => attrs[key]) || klass.new
    end
  end
end
