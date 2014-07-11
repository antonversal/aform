require 'active_model'
class Aform::Model
  include ActiveModel::Model

  def initialize(object, attributes = {}, destroy_key = :_destroy)
    @destroy = attributes.delete(destroy_key)
    @object = object
    @attributes = attributes_for_save(attributes)
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Aform::Model")
  end

  # AR saves children with parent if it's new object
  # but dont save children with parent when children is updated
  def save(association = nil)
    if @destroy
      @object.destroy
    else
      @object.assign_attributes(@attributes)
      association << @object if association
      @object.save
    end
  end

  def valid?
    @destroy || super
  end

  private

  def attributes_for_save(attributes)
    attrs = attributes.symbolize_keys
    params.inject({}) do |memo, p|
      if attrs[p[:field]]
        attr =
          if p.has_key?(:options) && p[:options].has_key?(:model_field)
            {p[:options][:model_field] => attrs[p[:field]]}
          else
            {p[:field] => attrs[p[:field]]}
          end
        memo.merge(attr)
      else
        memo
      end
    end
  end
end