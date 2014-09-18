require 'test_helper'

describe Aform::Errors do
  #TODO other way for mocking ...

  before do
    @mock_form = mock("form")
    @mock_form.stubs(:form_model).returns(stub(errors: stub(messages: {name: ["can't be blank"]})))
    @mock_form.stubs(:nested_forms).returns({comments: [
      stub(form_model: stub(errors: stub(messages: {message: ["can't be blank"]})),
           nested_forms: {
             authors: [stub(form_model: stub(errors: stub(messages: {name: ["can't be blank"]})), nested_forms: nil)]
           },
      ),
      stub(form_model: stub(errors: stub(messages: {author: ["can't be blank"]})),
           nested_forms: nil
      ),
      stub(form_model: stub(errors: stub(messages: {message: ["can't be blank"]})),
           nested_forms: {
             authors: [stub(form_model: stub(errors: stub(messages: {})), nested_forms: nil)]
           }
      )
    ]})
  end

  subject { Aform::Errors.new(@mock_form) }

  it "collects form model errors" do
    subject.messages.must_equal({name: ["can't be blank"], comments: {
     0 => {message: ["can't be blank"], authors: {0 => {name:["can't be blank"]}}},
     1 => {author: ["can't be blank"]},
     2 => {message: ["can't be blank"]}
    }})
  end
end