require 'test_helper'

describe Aform::Form do

  let(:mock_model_klass) do
    Class.new do
      def self.new_klass(*args)
        self
      end
      def initialize(*args)
      end
    end
  end

  describe ".param" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        param :size
      end.new({}, mock_model_klass)
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
      end.new({}, mock_model_klass)
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
      subject.new({name: "Name", count: 10}).must_be :valid?
    end

    it "returns false" do
      subject.new({}).wont_be :valid?
    end
  end
end

