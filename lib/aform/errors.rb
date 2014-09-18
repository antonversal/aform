module Aform
  class Errors
    def initialize(form)
      @form = form
    end

    def messages
      @form.form_model.errors.messages.merge(nested_messages(@form))
    end

    private

    def nested_messages(form)
      if nf = form.nested_forms
        nf.inject({}) do |memo, (k,v)|
          messages = v.each_with_index.inject({}) do |m, (e, i)|
            errors = e.form_model.errors.messages.merge(nested_messages(e))
            errors.present? ? m.merge(i => errors) : m
          end
          messages.present? ? memo.merge(k => messages) : memo
        end
      else
        {}
      end
    end
  end
end