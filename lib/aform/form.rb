module Aform
  class Form
    class_attribute :params
    class_attribute :validations
    class_attribute :nested_form_klasses

    attr_reader :form_model, :attributes, :nested_forms, :model

    def initialize(model, attributes, model_klass = Aform::Model,
      model_builder = Aform::Builder, errors_klass = Aform::Errors,
      transaction_klass = ActiveRecord::Base)
      @model_klass, @model_builder, @errors_klass = model_klass, model_builder, errors_klass
      @model, @attributes, @transaction_klass = model, attributes, transaction_klass
      creator = @model_builder.new(@model_klass)
      @form_model = creator.build_model_klass(self.params, self.validations).new(@model, @attributes)
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
      if self.valid?
        if @nested_forms
          @transaction_klass.transaction do
            nested_save = @nested_forms.values.flatten.map{|f| f.form_model.nested_save}
            model_save = @form_model.save
            raise(ActiveRecord::Rollback) unless nested_save.all? || model_save
            nested_save && model_save
          end
        else
          @form_model.save
        end
      end
    end

    def errors
      @errors_klass.new(self).messages
    end

    class << self
      def param(*args)
        self.params ||= []
        options = args.extract_options!
        elements = options.present? ? args.map{ |a| {a => options}} : args
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
          if attributes.has_key? k
            attributes[k].each do |attrs|
              @nested_forms ||= {}
              @nested_forms[k] ||= []
              model = nested_ar_model(k, attrs)
              @nested_forms[k] << v.new(model, attrs, @model_klass, @model_builder, @errors_klass, @transaction_klass)
            end
          end
        end
      end
    end

    def nested_ar_model(association, attrs)
      if attrs.has_key? :id
        @model.public_send(association).select{|e| e.id == attrs[:id]}.first
      else
        @model.public_send(association).build
      end
    end
  end
end
