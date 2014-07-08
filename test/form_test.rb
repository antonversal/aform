require 'test_helper'

describe Aform::Form do

  let(:ar_model) { mock("ar_model") }

  before do
    @mock_model_klass = mock("Aform::Model")
    @mock_model_klass.stubs(:new).returns(true)
    @mock_builder_instance = mock("Aform::BuilderInstance")
    @mock_builder_instance.stubs(:build_model_klass).returns(@mock_model_klass)
    @mock_builder_klass = mock("Aform::Builder")
    @mock_builder_klass.stubs(:new).returns(@mock_builder_instance)
  end

  describe ".param" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        param :size
      end.new(ar_model, {}, @mock_model_klass, @mock_builder_klass)
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
        validate do
          errors.add(:base, "Must be foo to be a bar")
        end
      end.new(ar_model, {}, @mock_model_klass, @mock_builder_klass)
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
      end
    end

    it "returns true" do
      subject.new(ar_model, {name: "Name", count: 10}).must_be :valid?
    end

    it "returns false" do
      subject.new(ar_model, {}).wont_be :valid?
    end
  end

  describe "#save" do
    it "calls model.save" do
      skip("investigate better mock")
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
        subject.comments.params.must_equal([:author, :message])
      end

      it "saves validations" do
        subject.comments.validations.must_equal([{method: :validates_presence_of, options: [:message, :author]}])
      end

      it "defines `nested_forms`" do
        subject.nested_forms.must_equal([subject.comments])
      end
    end
  end
end

