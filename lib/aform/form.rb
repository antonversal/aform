module Aform
  class Form
    class_attribute :params
    class_attribute :validations
    class_attribute :nested_form_klasses

    attr_accessor :model, :attributes, :nested_forms

    def initialize(ar_model, attributes, model_klass = Aform::Model,
      model_builder = Aform::Builder)

      creator = model_builder.new(model_klass)
      self.model = creator.build_model_klass(self.params, self.validations).new(ar_model, attributes)
      self.attributes = attributes
      initialize_nested(ar_model, model_klass, model_builder)
    end

    #TODO don't save all models if at leas one is fail

    def valid?
      if self.nested_forms
        self.model.valid? && self.nested_forms.values.flatten.all?(&:valid?)
      else
        self.model.valid?
      end
    end

    def save
      if self.nested_forms
        self.model.save && self.nested_forms.values.flatten.all?(&:save)
      else
        self.model.save
      end
    end

    def errors
      self.model.errors.messages
    end

    class << self
      def param(*args)
        self.params ||= []
        self.params += args
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

    def initialize_nested(ar_model, model_klass, model_builder)
      if nested_form_klasses
        nested_form_klasses.each do |k,v|
          if attributes.has_key? k
            attributes[k].each do |attrs|
              self.nested_forms ||= {}
              self.nested_forms[k] ||= []
              model = nested_ar_model(ar_model, k, attrs)
              self.nested_forms[k] << v.new(model, attrs, model_klass, model_builder)
            end
          end
        end
      end
    end

    def nested_ar_model(ar_model, association, attrs)
      if attrs.has_key? :id
        ar_model.public_send(association).find(attrs[:id])
      else
        ar_model.public_send(association).build
      end
    end
  end
end
