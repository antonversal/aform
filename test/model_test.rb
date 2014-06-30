require 'test_helper'

describe Aform::Model do
  subject do
    fields = [:name, :full_name]
    validations = [{method: :validates_presence_of, options: [:name]}]
    Aform::Model.new(fields, validations)
  end

  describe "validations" do
    it "is not valid" do
      subject.wont_be :valid?
    end

    it "is valid" do
      subject.assign_attributes(name: "the name")
      subject.must_be :valid?
    end
  end
end