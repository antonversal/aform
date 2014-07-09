require_relative './integration_helper'

class PostForm < Aform::Form
  param :title, :author
  validates_presence_of :title, :author

  has_many :comments do
    param :message, :author
    validates_presence_of :message, :author
  end
end

describe "ActiveRecord" do
  #TODO: move to helper in some way
  after do
    Comment.delete_all
    Post.delete_all
  end

  describe "creating records" do
    it "creates record" do
      post = Post.new
      attrs = {title: "Cool Post", author: "John Doe",
               comments: [
                 {message: "Great post man!", author: "Mr. Smith"},
                 {message: "Really?", author: "Vasya"}
               ]
      }
      form = PostForm.new(post,attrs)
      form.save.must_equal true
      Post.count.must_equal 1
      Comment.count.must_equal 2
      post = Post.first
      post.title.must_equal("Cool Post")
      post.author.must_equal("John Doe")
      comments = post.comments
      comments.map(&:message).must_equal(["Great post man!", "Really?"])
      comments.map(&:author).must_equal(["Mr. Smith", "Vasya"])
    end
  end
end