module Aform
  class Form
    class_attribute :params
    class_attribute :validations

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
