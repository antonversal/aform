require 'test_helper'

describe Aform::Form do

  let(:ar_model) { mock("ar_model") }

  let(:mock_model_klass) do
    Class.new do
      def initialize(*args); end
    end
  end

  let(:mock_builder_klass) do
    Class.new do
      def initialize(*args); end
      def build_model_klass(*args)
        Class.new do
          def initialize(*args); end
        end
      end
    end
  end

  describe ".param" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        param :size
      end.new(ar_model, {}, mock_model_klass, mock_builder_klass)
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
      end.new(ar_model, {}, mock_model_klass, mock_builder_klass)
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
    end
  end
end

