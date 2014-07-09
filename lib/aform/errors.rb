module Aform
  class Errors
    def initialize(form)
      @form = form
    end

    def messages
      @form.model.errors.messages.merge(nested_messages(@form))
    end

    private

    def nested_messages(form)
      if nf = form.nested_forms
        nf.inject({}) do |memo, (k,v)|
          messages = v.map do |e|
            e.model.errors.messages.merge(nested_messages(e))
          end
          memo.merge(k => messages)
        end
      else
        {}
      end
    end
  end
end