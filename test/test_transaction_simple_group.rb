# -*- ruby encoding: utf-8 -*-

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0

require 'transaction/simple/group'
require 'minitest'

module Transaction::Simple::Test
  class Group < Minitest::Test #:nodoc:
    VALUE1  = "Hello, you."
    VALUE2  = "And you, too."

    def setup
      @x = VALUE1.dup
      @y = VALUE2.dup
    end

    def test_group
      group = Transaction::Simple::Group.new(@x, @y)

      group.start_transaction(:first)
      assert_equal(true, group.transaction_open?(:first))
      assert_equal(true, @x.transaction_open?(:first))
      assert_equal(true, @y.transaction_open?(:first))

      assert_equal("Hello, world.", @x.gsub!(/you/, "world"))
      assert_equal("And me, too.", @y.gsub!(/you/, "me"))

      group.start_transaction(:second)
      assert_equal("Hello, HAL.", @x.gsub!(/world/, "HAL"))
      assert_equal("And Dave, too.", @y.gsub!(/me/, "Dave"))

      group.rewind_transaction(:second)
      assert_equal("Hello, world.", @x)
      assert_equal("And me, too.", @y)

      assert_equal("Hello, HAL.", @x.gsub!(/world/, "HAL"))
      assert_equal("And Dave, too.", @y.gsub!(/me/, "Dave"))

      group.commit_transaction(:second)
      assert_equal("Hello, HAL.", @x)
      assert_equal("And Dave, too.", @y)

      group.abort_transaction(:first)
      assert_equal("Hello, you.", @x)
      assert_equal("And you, too.", @y)
    end
  end
end

# vim: syntax=ruby
