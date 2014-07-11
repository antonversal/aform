require 'test_helper'

describe Aform::FormSaver do
  class TransactionKlass
    def self.transaction
      yield
    end
  end

  class TestForm
    def form_model

    end

    def nested_forms
      {comments: }
    end
  end

  let(:form) do
    OpenStruct
    form = {
      form_model: :form_model,
      nested_forms: [
        {comments: [
                    nested_form1: {
                      form_model: :form_model,
                      nested_forms: [:nested_form2]
                    }
          ]
        }
      ]
    }
  end

  subject { Aform::FormSaver.new(form, TransactionKlass) }

  it "saves form" do

  end
end