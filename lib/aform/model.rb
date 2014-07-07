require 'active_model'
class Aform::Model
  include ActiveModel::Model

  def initialize(attributes = {})
    @attributes = attributes
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Aform::Model")
  end
end