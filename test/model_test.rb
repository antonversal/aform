require 'test_helper'

describe Aform::Model do
  subject { Aform::Model.new_klass(fields, validations) }

  context "validations" do
    context "simple" do
      let(:fields){ [:name, :full_name] }
      let(:validations){ [{method: :validates_presence_of, options: [:name]}] }

      it "is not valid" do
        subject.new.wont_be :valid?
      end

      it "is valid" do
        subject.new(name: "the name").must_be :valid?
      end
    end

    context "when block is given" do
      let(:fields){ [:name, :full_name] }
      let(:validations){ [{method: :validates_presence_of, options: [:name]}] }
    end
  end
end