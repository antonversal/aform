require 'test_helper'

describe Aform::Model do
  subject { Aform::Builder.new(Aform::Model).build_model_klass(fields, validations) }

  context "validations" do
    context "by type" do
      let(:fields){ [:name, :full_name] }
      let(:validations){ [{method: :validates_presence_of, options: [:name]}] }

      it "is not valid" do
        subject.new.wont_be :valid?
      end

      it "is valid" do
        subject.new(name: "the name").must_be :valid?
      end
    end

    context "validate" do
      let(:fields){ [:name, :count] }
      let(:validations){ [{method: :validates, options: [:count, {presence: true, inclusion: {in: 1..100}}]}] }

      it "is not valid" do
        subject.new(count: -1).wont_be :valid?
      end

      it "is valid" do
        subject.new(name: "the name", count: 3).must_be :valid?
      end
    end

    #context "when block is given" do
    #  let(:fields){ [:name, :full_name] }
    #  let(:validations) do
    #    [{method: :validate, block: ->{errors.add(:base, "must be foo")}}]
    #  end
    #
    #  it "is not valid" do
    #    binding.pry
    #    subject.new.wont_be :valid?
    #  end
    #end
  end
end