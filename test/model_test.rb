require 'test_helper'

describe Aform::Model do
  subject { Aform::Builder.new(Aform::Model).build_model_klass(fields, validations) }

  let(:ar_model) { mock("ar_model") }

  context "validations" do
    context "by type" do
      let(:fields){ [{field: :name}, {field: :full_name}] }
      let(:validations){ [{method: :validates_presence_of, options: [:name]}] }

      it "is not valid" do
        subject.new(ar_model).wont_be :valid?
      end

      it "is valid" do
        subject.new(ar_model, name: "the name").must_be :valid?
      end
    end

    context "validate" do
      let(:fields){ [{field: :name}, {field: :count}] }
      let(:validations){ [{method: :validates, options: [:count, {presence: true, inclusion: {in: 1..100}}]}] }

      it "is not valid" do
        subject.new(ar_model, count: -1).wont_be :valid?
      end

      it "is valid" do
        subject.new(ar_model, name: "the name", count: 3).must_be :valid?
      end
    end

    context "when block is given" do
      let(:fields){ [{field: :name}, {field: :full_name}] }
      let(:validations) do
        [{method: :validate, block: ->{errors.add(:base, "must be foo")}}]
      end

      it "is not valid" do
        skip("not implemented")
      end
    end

    context "when marked for destruction" do
      let(:fields){ [{field: :name}, {field: :count}] }
      let(:validations){ [{method: :validates_presence_of, options: [:name]}] }

      it "is not valid" do
        subject.new(ar_model, _destroy: true).must_be :valid?
      end
    end
  end

  describe "#save" do
    let(:fields){ [{field: :name}, {field: :count}] }
    let(:validations){ [] }

    let(:form_model) { subject.new(ar_model, name: "name", count: 2, other_attr: "other")}

    it "calls `ar_model.assign_attributes`" do
      ar_model.expects(:assign_attributes).with(name: "name", count: 2).returns(true)
      ar_model.stubs(:save)
      form_model.save
    end

    it "calls `ar_model.save`" do
      ar_model.stubs(:assign_attributes).returns(true)
      ar_model.expects(:save).returns(true)
      form_model.save
    end

    context "when keys are strings" do
      let(:form_model) { subject.new(ar_model, "name" => "name", "count" => 2, "other_attr" => "other")}

      it "calls `ar_model.assign_attributes`" do
        ar_model.expects(:assign_attributes).with(name: "name", count: 2).returns(true)
        ar_model.stubs(:save)
        form_model.save
      end
    end

    context "when fields with model_field option" do
      let(:fields){ [{field: :name}, {field: :count, options: {model_field: :size}}] }

      it "convert attributes" do
        ar_model.expects(:assign_attributes).with(name: "name", size: 2).returns(true)
        ar_model.stubs(:save)
        form_model.save
      end
    end
  end

  describe "#nested_save" do
    let(:fields){ [{field: :name}, {field: :count}] }
    let(:validations){ [] }
    let(:form_model) { subject.new(ar_model, name: "name", count: 2, other_attr: "other")}

    it "calls `ar_model.assign_attributes`" do
      ar_model.expects(:assign_attributes).with(name: "name", count: 2).returns(true)
      ar_model.stubs(:persisted?).returns(false)
      form_model.nested_save
    end

    it "calls `ar_model.save` if persisted? is true" do
      ar_model.stubs(:assign_attributes).returns(true)
      ar_model.stubs(:persisted?).returns(true)
      ar_model.expects(:save).returns(true)
      form_model.nested_save
    end

    context "when marked for destruction" do
      let(:form_model) { subject.new(ar_model, name: "name", count: 2, _destroy: true)}
      it "removes element" do
        ar_model.expects(:destroy).returns(true)
        form_model.nested_save
      end

      it "calls `ar_model.assign_attributes`" do
        ar_model.expects(:assign_attributes).with(name: "name", count: 2).returns(true)
        form_model.nested_save
      end
    end
  end
end