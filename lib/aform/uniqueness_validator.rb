require 'active_record'
class UniquenessValidator < ::ActiveRecord::Validations::UniquenessValidator
  def validate_each(form, attribute, value)
    object = form.instance_variable_get(:@object)
    @klass = object.class
    super(object, attribute, value).tap do |res|
      form.errors.add(attribute, object.errors.first.last) if object.errors.present?
    end
  end
end