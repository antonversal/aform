require 'test_helper'

describe Aform::Errors do
  #TODO other way for mocking ...

  before do
    @mock_form = mock("form")
    @mock_form.stubs(:model).returns(stub(errors: stub(messages: {name: ["can't be blank"]})))
    @mock_form.stubs(:nested_forms).returns({comments: [
      stub(model: stub(errors: stub(messages: {message: ["can't be blank"]})),
           nested_forms: {
             authors: [stub(model: stub(errors: stub(messages: {name: ["can't be blank"]})), nested_forms: nil)]
           },
      ),
      stub(model: stub(errors: stub(messages: {author: ["can't be blank"]})),
           nested_forms: nil
      ),
    ]})
  end

  subject { Aform::Errors.new(@mock_form) }

  it "collects form model errors" do
    subject.messages.must_equal({name: ["can't be blank"], comments: [
      {message: ["can't be blank"], authors: [{name:["can't be blank"]}]},
      {author: ["can't be blank"]}
    ]})
  end
end