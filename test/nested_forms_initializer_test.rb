require 'test_helper'

describe Aform::NestedFormsInitializer do
  it "initializes nested forms" do
    nested_form_klasses = {comments: [OpenStruct.new, OpenStruct.new]}
    mock_record = OpenStruct.new

    attributes = {
      comments: [
        {message: "Message 1", author: "Author 1"},
        {message: "Message 2", author: "Author 2"}
      ]}

    nfi = Aform::NestedFormsInitializer.new(nested_form_klasses, attributes, mock_record)
    nfi.init.must_equal(comments: [])
  end

end