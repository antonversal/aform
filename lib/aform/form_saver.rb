module Aform
  class FormSaver
    attr_reader :transaction_klass, :rollback_klass

    def initialize(form, opts = {})
      @transaction_klass = opts[:transaction_klass] ||= ActiveRecord::Base
      @rollback_klass = opts[:rollback_klass] ||= ActiveRecord::Rollback
      @form = form
    end

    def save
      result = false
      @transaction_klass.transaction do
        result =
          if @form.nested_forms
            @form.form_model.save && save_nested(@form).all?
          else
            @form.form_model.save
          end
        raise(@rollback_klass) unless result
      end
      result
    end

    protected

    def save_nested(form)
      form.nested_forms.map do |k, v|
        v.map do |nf|
          result = nf.form_model.save(form.record.send(k))
          save_nested(nf) if nf.nested_forms
          result
        end
      end.flatten
    end
  end
end
