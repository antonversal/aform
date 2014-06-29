require 'test_helper'

describe Aform::Form do

  describe ".param" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        param :size
      end.new
    end

    it "stores params" do
      subject.params.must_equal([:name, :count, :size])
    end
  end

  describe "validation remembering" do

    subject do
      Class.new(Aform::Form) do
        param :name, :count
        validates_presence_of :name
        validates :count, presence: true, inclusion: [1..100]
        validate :custom_validation
      end.new
    end

    it "saves validation" do
      validations = [
        {method: :validates_presence_of, options: [:name]},
        {method: :validates, options: [:count, {presence: true, inclusion: [1..100]}]},
        {method: :validate, options: [:custom_validation]}
      ]
      subject.validations.must_equal(validations)
    end
  end
end

