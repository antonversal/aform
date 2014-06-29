require 'test_helper'


describe Aform::Form do
  describe ".param" do
    class FooForm < Aform::Form
      param :name, :count
      param :size
    end

    let(:foo) { FooForm.new }
    let(:bar) { BarForm.new }

    it "stores params" do
      foo.params.must_equal [:name, :count, :size]
    end
  end
end

