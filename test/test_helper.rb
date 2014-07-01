require 'aform'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest/emoji'
require 'pry'

module MiniTest
  class Spec
    class << self
      alias_method :context, :describe
    end
  end
end