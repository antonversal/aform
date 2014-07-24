require 'test_helper'

describe Aform::Model do
  subject { Aform::Model.build_klass(fields, validations) }

  def mock_ar_model(attributes: {}, save: true)
    model = OpenStruct.new(attributes: attributes, save: save)
    model.define_singleton_method :assign_attributes do |attrs|
      @table[:attributes] = attrs
    end
    model
  end

  def mock_form
    OpenStruct.new
  end

  context "validations" do
    context "by type" do
      let(:fields){ [{field: :name}, {field: :full_name}] }
      let(:validations){ [{method: :validates_presence_of, options: [:name]}] }

      it "is not valid" do
        subject.new(mock_ar_model, mock_form).wont_be :valid?
      end

      it "is valid" do
        subject.new(mock_ar_model, mock_form, {name: "the name"}).must_be :valid?
      end
    end

    context "validate" do
      let(:fields){ [{field: :name}, {field: :count}] }
      let(:validations){ [{method: :validates, options: [:count, {presence: true, inclusion: {in: 1..100}}]}] }

      it "is not valid" do
        subject.new(mock_ar_model, mock_form, count: -1).wont_be :valid?
      end

      it "is valid" do
        subject.new(mock_ar_model, mock_form, name: "the name", count: 3).must_be :valid?
      end
    end

    context "when block is given" do
      let(:fields){ [{field: :name}, {field: :full_name}] }
      let(:validations) do
        [{method: :validate, block: ->{errors.add(:base, "must be foo")}}]
      end

      let(:model) {subject.new(mock_ar_model, mock_form, {})}

      it "is not valid" do
        model.wont_be :valid?
      end

      it "adds errors" do
        model.valid?
        model.errors.messages.must_equal(base: ["must be foo"])
      end
    end
  end

  describe "#save" do
    let(:fields){ [{field: :name}, {field: :count}] }
    let(:validations){ [] }
    let(:model) { mock_ar_model }
    let(:form_model) { subject.new(model, mock_form, name: "name", count: 2, other_attr: "other")}

    it "assigns attributes to model" do
      form_model.save
      model.attributes.must_equal({name: "name", count: 2})
    end

    it "saves model" do
      model.expects(:save)
      form_model.save
    end

    context "when keys are strings" do
      let(:form_model) { subject.new(model, mock_form,
                                     "name" => "name",
                                     "count" => 2,
                                     "other_attr" => "other")}

      it "calls assigns attributes" do
        form_model.save
        model.attributes.must_equal(name: "name", count: 2)
      end
    end

    context "when fields with model_field option" do
      let(:fields){ [{field: :name}, {field: :count, options: {model_field: :size}}] }

      it "convert attributes" do
        form_model.save
        model.attributes.must_equal(name: "name", size: 2)
      end
    end

    context "when association is given" do
      let(:association) {[]}
      before do
        form_model.save(association)
      end

      it "adds object to association" do
        association.must_equal([model])
      end
    end
  end

  context "when object for destroying" do
    let(:fields){ [{field: :name}, {field: :count}] }
    let(:validations){ [{method: :validates_presence_of, options: [:name]}] }
    let(:model) { mock_ar_model }
    let(:form_model) { subject.new(model, mock_form, count: 2, _destroy: true)}

    it "is valid" do
      form_model.must_be :valid?
    end

    it "assigns attributes" do
      form_model.save
      model.attributes.must_equal(count: 2)
    end
  end
end