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
#end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end