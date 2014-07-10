require 'active_model'
class Aform::Model
  include ActiveModel::Model

  def initialize(object, attributes = {}, destroy_key = :_destroy)
    @destroy = attributes.delete(destroy_key)
    @attributes = attributes.select{|k,v| params.include? k.to_sym }
    @object = object
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Aform::Model")
  end

  # AR saves children with parent if it's new object
  # but dont save children with parent when children is updated
  def nested_save
    if @destroy
      @object.destroy
    else
      @object.assign_attributes(@attributes)
      if @object.persisted?
        @object.save
      else
        true
      end
    end
  end

  def save
    @object.assign_attributes(@attributes)
    @object.save
  end

  def valid?
    @destroy || super
  end
end