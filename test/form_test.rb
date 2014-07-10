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
    @mock_transaction = mock("ar_model")
    @mock_errors = mock("mock_errors")
  end

  describe ".param" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        param :size, model_field: :count
      end.new(ar_model, {}, @mock_model_klass, @mock_builder_klass, @mock_errors, @mock_transaction)
    end

    it "stores params" do
      subject.params.must_equal([:name, :count, {size: {model_field: :count}}])
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
      end.new(ar_model, {}, @mock_model_klass, @mock_builder_klass, @mock_errors, @mock_transaction)
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
      end.new(ar_model, {}, @mock_model_klass, @mock_builder_klass, @mock_errors, @mock_transaction)
    end

    it "calls valid? on model" do
      @mock_model_instance.expects(:valid?)
      subject.valid?
    end
  end

  describe "#save" do
    subject do
      Class.new(Aform::Form) do
        param :name, :count
        validates_presence_of :name
        validates :count, presence: true, inclusion: {in: 1..100}
      end.new(ar_model, {}, @mock_model_klass, @mock_builder_klass, @mock_errors, @mock_transaction)
    end

    it "calls model.save" do
      subject.stubs(:valid?).returns(true)
      @mock_model_instance.expects(:save)
      subject.save
    end
  end

  describe "#errors" do
    #subject do
    #  Class.new(Aform::Form) do
    #    param :name, :count
    #    validates_presence_of :name
    #    validates :count, presence: true, inclusion: {in: 1..100}
    #  end.new(ar_model, {}, @mock_model_klass, @mock_builder_klass)
    #end
    #
    #it "calls model.errors" do
    #  @mock_model_instance.expects(:errors)
    #  subject.errors
    #end
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
                                         {author: "Smith", message: "Message 2"}]},
                      @mock_model_klass, @mock_builder_klass, @mock_errors, @mock_transaction)
        end

        context "when `id` is present" do
          it "finds model for nested form" do
            model = mock("ar_model")
            relation = mock("relation")
            relation.stubs(:build)
            #TODO: rewirte tests
            relation.expects(:select).returns([1])
            model.stubs(comments: relation)
            subject.new(model, {name: "name", count: 1,
                                comments: [{author: "Joe", message: "Message 1"},
                                           {id: 21, author: "Smith", message: "Message 2"}]},
                        @mock_model_klass, @mock_builder_klass, @mock_errors, @mock_transaction)
          end
        end
      end

      #describe "#valid?" do
      #  it "calls valid? on nested forms" do
      #    Aform::Model.any_instance.expects(:valid?).returns(true).times(3)
      #    model = mock("ar_model")
      #    @mock_model_instance.stubs(:valid?).returns(true)
      #    model.stubs(comments: stub(build: mock("ar_comment_model")))
      #    form = subject.new(model, {name: "name", count: 1,
      #                               comments: [{author: "Joe", message: "Message 1"},
      #                                          {author: "Smith", message: "Message 2"}]},
      #                       @mock_model_klass, @mock_builder_klass, @mock_errors, @mock_transaction)
      #    form.valid?
      #  end
      #
      #  #it "calls valid? on nested forms when main form is not valid" do
      #  #  Aform::Model.any_instance.expects(:valid?).returns(false).times(3)
      #  #  model = mock("ar_model")
      #  #  model.stubs(comments: stub(build: mock("ar_comment_model")))
      #  #  form = subject.new(model, {name: "name", count: 1,
      #  #                             comments: [{author: "Joe", message: "Message 1"},
      #  #                                        {author: "Smith", message: "Message 2"}]},
      #  #                     @mock_model_klass, @mock_builder_klass, @mock_errors, @mock_transaction)
      #  #  form.valid?
      #  #end
      #end

      #describe "#save" do
      #  before do
      #    model = mock("ar_model")
      #    model.stubs(comments: stub(build: mock("ar_comment_model")))
      #    @mock_model_instance.stubs(:valid?).returns(true)
      #    @form = subject.new(model, {name: "name", count: 1,
      #                               comments: [{author: "Joe", message: "Message 1"},
      #                                          {author: "Smith", message: "Message 2"}]},
      #                        @mock_model_klass, @mock_builder_klass, @mock_errors, @mock_transaction)
      #  end
      #
      #  it "calls save on nested forms" do
      #    Aform::Model.any_instance.expects(:save).returns(true).times(3)
      #    @form.save
      #  end
      #
      #  it "calls valid? on nested forms" do
      #    Aform::Model.any_instance.expects(:valid?).returns(false).times(3)
      #    @form.save
      #  end
      #end
    end
  end
end

