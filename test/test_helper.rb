require 'aform'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest/emoji'
require 'pry'

I18n.enforce_available_locales = false

module MiniTest
  class Spec
    class << self
      alias_method :context, :describe
    end
  end
end