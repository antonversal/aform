require 'test_helper'

describe Aform::Model do
  subject do
    fields = [:name, :full_name]
    validations = [{method: :validates_presence_of, options: [:name]}]
    Aform::Model.new_klass(fields, validations)
  end

  context "validations" do
    it "is not valid" do
      subject.new.wont_be :valid?
    end

    it "is valid" do
      subject.new(name: "the name").must_be :valid?
    end
  end
end