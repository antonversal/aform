module Aform
  class Form
    class_attribute :params
    self.params = []

    class << self
      def param(*args)
        self.params += args
      end
    end
  end
end
