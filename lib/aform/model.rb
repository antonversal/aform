require 'active_model'
class Aform::Model
  include ActiveModel::Model

  def initialize(object, form, attributes = {}, destroy_key = :_destroy)
    @destroy = attributes.delete(destroy_key)
    @object = object
    @form = form
    sync_with_model
    @attributes.merge! attributes_for_save(attributes)
  end

  def self.build_klass(params, validations, builder = Aform::Builder.new(Aform::Model))
    builder.build_model_klass(params, validations)
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Aform::Model")
  end

  def self.validates_uniqueness_of(*attr_names)
    validates_with UniquenessValidator, _merge_attributes(attr_names)
  end

  # AR saves children with parent if it's new object
  # but dont save children with parent when children is updated
  def save(association = nil)
    @object.assign_attributes(@attributes)
    if @destroy
      @object.destroy
    else
      association << @object if association
      @object.save
    end
  end

  def valid?
    @destroy || super
  end

  private

  def sync_with_model
    attrs = @object.attributes.symbolize_keys
    @attributes = attributes_for_save(attrs)
  end

  def attributes_for_save(attributes)
    attrs = attributes.symbolize_keys
    params.inject({}) do |memo, p|
      field_name = get_field_name(p)
      if @form.respond_to?(p[:field])
        memo.merge(field_name => @form.public_send(p[:field], attrs))
      else
        if attrs.has_key?(p[:field])
          memo.merge(field_name => attrs[p[:field]])
        else
          memo
        end
      end
    end
  end

  def get_field_name(p)
    if p.has_key?(:options) && p[:options].has_key?(:model_field)
      p[:options][:model_field]
    else
      p[:field]
    end
  end
end