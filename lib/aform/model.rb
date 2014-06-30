require 'active_model'
class Aform::Model
  include ActiveModel::Model

  def initialize(params, validations)
    @params = params
    @validations = validations
    @attributes = {}
    define_params_methods
    define_validations
  end

  def assign_attributes(attributes = {})
    @attributes = attributes
  end

  private

  def define_params_methods
    @params.each do |p| 
      self.class.send(:define_method, p) { @attributes[p] }
    end
  end

  def define_validations
    @validations.each do |v|
      self.class.send(v[:method], v[:options])
    end
  end
end