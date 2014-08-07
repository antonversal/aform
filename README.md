# Aform [![Build Status](https://travis-ci.org/antonversal/aform.svg?branch=master)](https://travis-ci.org/antonversal/aform) [![Code Quality](https://codeclimate.com/github/antonversal/aform.png)](https://codeclimate.com/github/antonversal/aform)

Aform lets you define Form Object with validatins and ability save difficult `jsons` or `form params` to models. You can create Form object with nested forms for storing `has_many` associations with parent model.

It was developed for [rails-api](https://github.com/rails-api/rails-api) and ActiveRecord. 

## Installation

Add this line to your application's Gemfile:

    gem 'aform', '~>0.0.7'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aform

## Usage
### Define Form

Definning form is pretty simple, for instance you have posts wich have comments and comments have likes:

```ruby
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
```
Method `param` is used for adding params wich will be used for saving models. You can add any validation you need for each param. 

### Setup controller
``` ruby
class PostsController < ApplicationController

  def create
    form = PostForm.new(Post.new, params[:post])
    if form.save
      render json: form.model, status: :created
    else
      render json: {errors: form.errors}, status: :unprocessable_entity
    end
  end
  
  def update
    post = Post.find(params[:id])
    form = PostForm.new(post, params[:post])
    if form.save
      render json: form.model
    else
      render json: {errors: form.errors}, status: :unprocessable_entity
    end
  end

end
```

### Delete nested records

For deleting nested records you should set `_destroy` key to `true` in nested params:
```ruby
post = {
  title: "Very Cool Post", 
  author: "John Doe",
  comments: [ {id: comment.id, _destroy: true}]
 }
```

### Params
Before looking up the param in a given hash, a form object will check for the presence of a method with the name of the param:
```ruby
post = {
  title: "Cool Post", 
  first_author: "John Doe", 
  second_author: "Mr. Author"
}
```
Form Object:
``` ruby
class OtherPostForm < Aform::Form
  param :title, :author

  def author(attributes)
    "#{attributes[:first_author]} and #{attributes[:second_author]}"
  end
end
```

When you need just save method with other name you can use `:model_field` option:

``` ruby
param :first_author, model_field: :author
```

### Validations
Aform curruntly support standart ActiveModel validations like:
```ruby
validates_presence_of :title
validates :count, presence: true, inclusion: [1..100]
```
And ActiveRecord uniqueness validation `validates_uniqueness_of` or `validates :title, uniqueness: true`
But it doesn't support yet validation with block and a symbol pointing to a method, supporting will be added in short future.

## Contributing

1. Fork it ( https://github.com/antonversal/aform )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
