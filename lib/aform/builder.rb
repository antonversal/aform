require 'active_model'
class Aform::Builder
  def initialize(model_klass)
    @model_klass = model_klass
  end

  def build_model_klass(params, validations)
    Class.new(@model_klass) do
      class_attribute :params

      self.params = params

      validations.each do |v|
        send(v[:method], *v[:options])
      end if validations

      params.each do |p|
        self.send(:define_method, p) { @attributes[p] }
      end if params
    end
  end
end