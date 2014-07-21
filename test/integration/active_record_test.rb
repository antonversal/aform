require_relative './integration_helper'

describe "saving" do

  context "basic functionality" do
    class PostForm < Aform::Form
      param :title, :author
      validates_presence_of :title, :author

      has_many :comments do
        param :message, :author
        validates_presence_of :message, :author

        has_many :likes do
          param :author
          validates_presence_of :author
        end
      end
    end

    #TODO: move to helper in some way
    after do
      Comment.delete_all
      Post.delete_all
      Like.delete_all
    end

    it "creates records" do
      post = Post.new
      attrs = {title: "Cool Post", author: "John Doe",
               comments: [
                 {message: "Great post man!", author: "Mr. Smith"},
                 {message: "Really?", author: "Vasya"}
               ]
      }
      form = PostForm.new(post, attrs)
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

    it "updates records" do
      post = Post.create(title: "Cool Post", author: "John Doe")
      comment = post.comments.create(message: "Great post man!", author: "Mr. Smith")

      attrs = {title: "Very Cool Post",
               comments: [
                 {id: comment.id, message: "Great post MAN!", author: "Mr. Smith"},
                 {message: "Really?", author: "Vasya"}
               ]
      }
      post.reload
      form = PostForm.new(post, attrs)
      form.save.must_equal true
      Post.count.must_equal 1
      Comment.count.must_equal 2
      post = Post.first
      post.title.must_equal("Very Cool Post")
      post.author.must_equal("John Doe")
      comments = post.comments
      comments.map(&:message).must_equal(["Great post MAN!", "Really?"])
      comments.map(&:author).must_equal(["Mr. Smith", "Vasya"])
    end

    it "delete nested records" do
      post = Post.create(title: "Cool Post", author: "John Doe")
      comment = post.comments.create(message: "Great post man!", author: "Mr. Smith")
      post.comments.create(message: "Really?", author: "Vasya")
      attrs = {title: "Very Cool Post", author: "John Doe",
               comments: [
                 {id: comment.id, _destroy: true}
               ]
      }
      post.reload
      form = PostForm.new(post, attrs)
      form.save.must_equal true
      Comment.count.must_equal 1
      post = Post.first
      comment = post.comments.first
      comment.message.must_equal("Really?")
      comment.author.must_equal("Vasya")
    end

    it "return validation errors" do
      post = Post.new
      attrs = {title: "Cool Post",
               comments: [
                 {message: "Great post man!"},
                 {author: "Vasya"}
               ]
      }
      form = PostForm.new(post, attrs)
      form.wont_be :valid?
      form.errors.must_equal({author: ["can't be blank"], comments: {0 => {author: ["can't be blank"]},
                                                                     1 => {message: ["can't be blank"]}}})
    end

    it "creates 3rd nested records" do
      post = Post.new
      attrs = {title: "Cool Post", author: "John Doe",
               comments: [
                 {message: "Great post man!",
                  author: "Mr. Smith",
                  likes: [{author: "Vasya"}]},
               ]
      }
      form = PostForm.new(post, attrs)
      form.save.must_equal true
      Post.count.must_equal 1
      Comment.count.must_equal 1
      Like.count.must_equal 1
    end

    context "when nested is nil" do
      it "saves without nested" do
        post = Post.new
        attrs = {title: "Cool Post", author: "John Doe",
                 comments: nil}
        form = PostForm.new(post, attrs)
        form.save.must_equal true
      end
    end
  end

  context "attributes from method" do
    class OtherPostForm < Aform::Form
      param :title, :author

      def author(attributes)
        "#{attributes[:first_author]} and #{attributes[:second_author]}"
      end
    end

    after do
      Post.delete_all
    end

    it "inherits attribute from parent" do
      post = Post.new
      attrs = {title: "Cool Post", first_author: "John Doe", second_author: "Mr. Author"}
      form = OtherPostForm.new(post, attrs)
      form.save.must_equal true
      post = Post.first
      post.author.must_equal("John Doe and Mr. Author")
    end
  end

  context "validate uniqueness" do
    class Other2PostForm < Aform::Form
      param :title
      validates :title, uniqueness: true

      has_many :comments do
        param :message, :author
        validates_uniqueness_of :message
      end
    end

    before do
      Post.create!(title: "test")
      Comment.create!(message: "test")
    end

    after do
      Post.delete_all
      Comment.delete_all
    end

    it "inherits attribute from parent" do
      post = Post.new
      attrs = {title: "test", comments: [{message: "test"}]}
      form = Other2PostForm.new(post, attrs)
      form.save.must_equal false
      form.errors.must_equal({:title=>["has already been taken"],
                              :comments=>{0=>{:message=>["has already been taken"]}}})
    end
  end
end