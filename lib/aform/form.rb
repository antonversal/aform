module Aform
  class Form
    class_attribute :params, :pkey, :validations, :nested_form_klasses

    attr_reader :form_model, :attributes, :nested_forms, :record, :parent

    def initialize(record, attributes, parent = nil, opts = {})
      @opts = opts
      @attributes = attributes
      @record = record
      @parent = parent
      assign_opts_instances
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
      self.valid? && @form_saver.save
    end

    def errors
      @errors.messages
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

    def assign_opts_instances
      @errors = @opts[:errors] || Aform::Errors.new(self)
      @form_saver = @opts[:form_saver] || Aform::FormSaver.new(self)
      @form_model = @opts[:form_model] || Aform::Model.\
        build_klass(self.params, self.validations).\
        new(record, self, attributes)
      @nested_forms_initializer =
        @opts[:nested_forms_initializer] || NestedFormsInitializer.\
        new(nested_form_klasses, @attributes, @record)
    end

    def initialize_nested
      @nested_forms = @nested_forms_initializer.init if nested_form_klasses
    end
  end
end