require 'test_helper'

describe Aform::FormSaver do
  class RollbackKlass < Exception
  end

  class TransactionKlass
    def self.transaction
      yield
    rescue RollbackKlass
      true
    end
  end

  def mock_nested_form(save = true)
    form_model = OpenStruct.new
    form_model.define_singleton_method :save do |*args|
      save
    end
    OpenStruct.new(nested_forms: nil,
                   form_model: form_model)
  end

  def mock_form(nested_forms: nil, record: nil, save: true)
    OpenStruct.new(nested_forms: nested_forms,
                   form_model: OpenStruct.new(save: save),
                   record: record)
  end

  def form_saver(form)
    Aform::FormSaver.new(form, {transaction_klass: TransactionKlass,
                                rollback_klass: RollbackKlass})
  end

  describe "#save" do
    context "saving form" do
      it "success" do
        form = mock_form
        form_saver(form).save.must_equal(true)
      end

      it "failure" do
        form = mock_form(save: false)
        form_saver(form).save.must_equal(false)
      end
    end

    context "saving nested forms" do
      it "success" do
        nested_forms = [mock_nested_form, mock_nested_form]
        form = mock_form(nested_forms: {comments: nested_forms},
                         record: OpenStruct.new(comments: []))
        form_saver(form).save.must_equal(true)
      end

      it "failure" do
        nested_forms = [mock_nested_form(false), mock_nested_form]
        form = mock_form(nested_forms: {comments: nested_forms},
                         record: OpenStruct.new(comments: []))
        form_saver(form).save.must_equal(false)
      end
    end
  end

  context "rollback transaction" do
    class TestTransactionKlass
      def self.transaction
        yield
      end
    end

    it "raises RollbackKlass" do
      form = mock_form(save: false)
      form_saver = Aform::FormSaver.new(form, {transaction_klass: TestTransactionKlass,
                                               rollback_klass: RollbackKlass})
      -> { form_saver.save }.must_raise(RollbackKlass)
    end
  end
end