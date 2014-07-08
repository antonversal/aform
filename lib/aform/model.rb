require 'active_model'
class Aform::Model
  include ActiveModel::Model

  def initialize(object, attributes = {})
    @attributes = attributes.select{|k,v| params.include? k }
    @object = object
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Aform::Model")
  end

  def save
    @object.assign_attributes(@attributes)
    @object.save
  end
end