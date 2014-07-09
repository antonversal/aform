require 'test_helper'

describe Aform::Form do

  let(:ar_model) { mock("ar_model") }

  before do
    @mock_model_instance = mock("model_instance")
    @mock_model_klass = mock("model_class")
    @mock_model_klass.stubs(:new).returns(@mock_model_instance)
    @mock_builder_instance = mock("builder_instance")
    @mock_builder_instance.stubs(:build_model_klass).returns(@mock_model_klass)
    @mock_builder_klass = mock("builder_class")
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
      end.new(ar_model, {}, @mock_model_klass, @mock_builder_klass)
    end

    it "calls valid? on model" do
      @mock_model_instance.expects(:valid?)
      subject.valid?
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
        subject.nested_form_klasses.must_equal({comments: subject.comments})
      end

      describe "initialization" do
        it "initializes nested froms" do
          model = mock("ar_model")
          relation = mock("relation")
          relation.expects(:build).times(2)
          model.stubs(comments: relation)
          subject.new(model, {name: "name", count: 1,
                              comments: [{author: "Joe", message: "Message 1"},
                                         {author: "Smith", message: "Message 2"}]})
        end

        context "when `id` is present" do
          it "finds model for nested form" do
            model = mock("ar_model")
            relation = mock("relation")
            relation.stubs(:build)
            relation.expects(:find).with(21).times(1)
            model.stubs(comments: relation)
            subject.new(model, {name: "name", count: 1,
                                comments: [{author: "Joe", message: "Message 1"},
                                           {id: 21, author: "Smith", message: "Message 2"}]})
          end
        end
      end

      describe "#valid?" do
        it "calls valid? on nested forms" do
          Aform::Model.any_instance.expects(:valid?).returns(true).times(3)
          model = mock("ar_model")
          model.stubs(comments: stub(build: mock("ar_comment_model")))
          form = subject.new(model, {name: "name", count: 1,
                                     comments: [{author: "Joe", message: "Message 1"},
                                                {author: "Smith", message: "Message 2"}]})
          form.valid?
        end
      end

      describe "#save?" do
        it "calls valid? on nested forms" do
          Aform::Model.any_instance.expects(:save).returns(true).times(3)
          model = mock("ar_model")
          model.stubs(comments: stub(build: mock("ar_comment_model")))
          form = subject.new(model, {name: "name", count: 1,
                                     comments: [{author: "Joe", message: "Message 1"},
                                                {author: "Smith", message: "Message 2"}]})
          form.save
        end
      end
    end
  end
end

