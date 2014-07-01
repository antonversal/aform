require 'active_model'
class Aform::Model
  include ActiveModel::Model

  def initialize(attributes = {})
    @attributes = attributes
  end

  def self.new_klass(params, validations)
    Class.new(self) do

      def self.model_name
        ActiveModel::Name.new(self, nil, "Aform::Model")
      end

      validations.each do |v|
        send(v[:method], v[:options])
      end

      params.each do |p|
        self.send(:define_method, p) { @attributes[p] }
      end
    end
  end
end