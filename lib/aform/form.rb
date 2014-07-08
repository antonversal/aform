module Aform
  class Form
    class_attribute :params
    class_attribute :validations
    class_attribute :nested_forms

    attr_accessor :model, :attributes

    def initialize(ar_model, attributes, model_klass = Aform::Model, model_builder = Aform::Builder)
      creator = model_builder.new(model_klass)
      self.model = creator.build_model_klass(self.params, self.validations).new(ar_model, attributes)
      self.attributes = attributes
    end

    def valid?
      self.model.valid?
    end

    def save
      self.model.save
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
      self.nested_forms ||= []
      class_attribute name
      klass = Class.new(Aform::Form, &block)
      self.send("#{name}=", klass)
      self.nested_forms << klass
    end
  end
end
