module Aform
  class Form
    class_attribute :params
    class_attribute :validations
    self.params = []
    self.validations = []

    class << self
      def param(*args)
        self.params += args
      end

      def method_missing(meth, *args, &block)
        if meth.to_s.start_with?("validate")
          self.validations << {method: meth, options: args}
        else
          super
        end
      end
    end
  end
end
