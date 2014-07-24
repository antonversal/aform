require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.name = "test:integration"
  t.pattern = 'test/integration/*_test.rb'
end

namespace :test do
  desc "Prepare test environment"
  task :prepare do
    require 'active_record'
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => "#{Dir.pwd}/database.sqlite3"
    )

    ActiveRecord::Schema.define do
      create_table :posts do |t|
        t.column :title, :string
        t.column :author, :string
        t.timestamps
      end

      create_table :comments do |t|
        t.column :message, :string
        t.column :author, :string
        t.belongs_to :post
      end

      create_table :likes do |t|
        t.column :author, :string
        t.belongs_to :comment
      end
    end
  end
end
