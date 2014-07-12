module Aform
  class FormSaver
    def initialize(form, transaction_klass = ActiveRecord::Base)
      @form = form
      @transaction_klass = transaction_klass
    end

    def save
      @transaction_klass.transaction do
        result =
          if @form.nested_forms
            @form.form_model.save && save_nested(@form).all?
          else
            @form.form_model.save
          end
        raise(ActiveRecord::Rollback) unless result
        result
      end
    end

    protected

    def save_nested(form)
      form.nested_forms.map do |k, v|
        v.map do |nf|
          result = nf.form_model.save(form.model.send(k))
          save_nested(nf) if nf.nested_forms
          result
        end
      end
    end
  end
end
