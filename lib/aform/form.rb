module Aform
  class Form
    class_attribute :params
    class_attribute :validations

    attr_accessor :model, :attributes

    def initialize(attributes, model_klass = Aform::Model)
      self.model = model_klass.new_klass(self.params, self.validations).new(attributes)
      self.attributes = attributes
    end

    def valid?
      self.model.valid?
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
        else
          super
        end
      end
    end
  end
end
