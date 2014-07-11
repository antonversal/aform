require_relative "../test_helper"

require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "#{Dir.pwd}/database.sqlite3"
)

#TODO: create task
#ActiveRecord::Schema.define do
#  create_table :posts do |t|
#    t.column :title, :string
#    t.column :author, :string
#    t.timestamps
#  end
#
#  create_table :comments do |t|
#    t.column :message, :string
#    t.column :author, :string
#    t.belongs_to :post
#  end
#
#  create_table :likes do |t|
#    t.column :author, :string
#    t.belongs_to :comment
#  end
#end

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