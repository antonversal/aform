require 'active_model'
#tested within model test
class Aform::Builder
  def initialize(model_klass)
    @model_klass = model_klass
  end

  def build_model_klass(params, validations)
    Class.new(@model_klass) do
      class_attribute :params

      self.params = params

      validations.each do |v|
        if v[:block]
          send(v[:method], v[:block])
        else
          send(v[:method], *v[:options])
        end
      end if validations

      params.each do |p|
        field = p[:field]
        self.send(:define_method, field) { @attributes[field] }
      end if params
    end
  end
end