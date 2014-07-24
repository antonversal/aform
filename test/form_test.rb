require 'test_helper'

describe Aform::Form do

  let(:record) { mock("record") }
  let(:form_model) {mock("form_model")}
  let(:form_saver) {mock("form_saver")}
  let(:errors) {mock("errors")}

  describe ".param" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        param :size, model_field: :count
      end
    end

    it "stores params" do
      subject.params.must_equal([{field: :name}, {field: :count}, {field: :size, options: {model_field: :count}}])
    end
  end

  describe "validation remembering" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        validates_presence_of :name
        validates :count, presence: true, inclusion: [1..100]
        validate :custom_validation
        validate do
          errors.add(:base, "Must be foo to be a bar")
        end
      end
    end

    it "saves validations" do
      subject.validations.size.must_be_same_as 4
    end

    it "saves `validates_presence_of` validation" do
      subject.validations.must_include({method: :validates_presence_of, options: [:name]})
    end

    it "saves `validates` validation" do
      subject.validations.must_include({method: :validates,
                                        options: [:count, {presence: true, inclusion: [1..100]}]})
    end

    it "saves `validate` validation" do
      subject.validations.last[:method].must_be_same_as(:validate)
      subject.validations.last[:block].wont_be_nil
    end
  end

  describe "#valid?" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        validates_presence_of :name
        validates :count, presence: true, inclusion: {in: 1..100}
      end.new(record, {}, nil, {form_model: form_model} )
    end

    it "calls valid? on form_model" do
      form_model.expects(:valid?)
      subject.valid?
    end
  end

  describe "#save" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        validates_presence_of :name
        validates :count, presence: true, inclusion: {in: 1..100}
      end.new(record, {}, nil, {form_saver: form_saver, form_model: form_model})
    end

    it "calls model.save" do
      subject.stubs(:valid?).returns(true)
      form_saver.expects(:save)
      subject.save
    end
  end

  describe "#errors" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        validates_presence_of :name
        validates :count, presence: true, inclusion: {in: 1..100}
      end.new(record, {}, nil, {form_saver: form_saver, form_model: form_model, errors: errors})
    end

    it "calls model.errors" do
      errors.expects(:messages)
      subject.errors
    end
  end

  describe "nested objects" do
    describe "has_many" do
      subject do
        Class.new(Aform::Form) do
          param :name, :count
          has_many :comments do
            param :author, :message
            validates_presence_of :message, :author
          end
        end
      end

      it "saves params" do
        subject.comments.params.must_equal([{field: :author}, {field: :message}])
      end

      it "saves validations" do
        subject.comments.validations.must_equal([{method: :validates_presence_of, options: [:message, :author]}])
      end

      it "defines `nested_forms`" do
        subject.nested_form_klasses.must_equal({comments: subject.comments})
      end
    end
  end
end

