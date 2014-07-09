require 'active_model'
class Aform::Model
  include ActiveModel::Model

  def initialize(object, attributes = {}, destroy_key = :_destroy)
    @destroy = attributes[destroy_key]
    @attributes = attributes.select{|k,v| params.include? k.to_sym }
    @object = object
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Aform::Model")
  end

  def save
    if @destroy
      @object.destroy
    else
      @object.assign_attributes(@attributes)
      @object.save
    end
  end

  def valid?
    @destroy || super
  end
end