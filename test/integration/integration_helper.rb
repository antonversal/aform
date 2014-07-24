require_relative "../test_helper"

require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "#{Dir.pwd}/database.sqlite3"
)

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
  has_many :likes
  validates_presence_of :message
end

class Like < ActiveRecord::Base
  belongs_to :comment
  validates_presence_of :author
end