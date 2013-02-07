# Copyright (c) 2013 Red Hat
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require './test/test_helper'
require './test/support/operation_support'


class TestLogger < MiniTest::Unit::TestCase

  def setup
    @operation = Trebuchet::Operation::SimpleBash.new
    @entry1 = Trebuchet::Entry.new({ :operation => @operation.class.name, :name => 'step_1' })
    @entry2 = Trebuchet::Entry.new({ :operation => @operation.class.name, :name => 'step_2' })
    Trebuchet::Logger.log_entry(@entry1)
  end

  def teardown
    Trebuchet::Logger.clear_log
  end

  def test_log_entry
    Trebuchet::Logger.log_entry(@entry2)

    refute_empty Trebuchet::Logger::RECORDS[@operation.class.name]
    assert_equal 2, Trebuchet::Logger::RECORDS[@operation.class.name].length
  end

  def test_dump_log
    dump = Trebuchet::Logger.dump_log

    refute_empty dump
  end

  def test_clear_log
    Trebuchet::Logger.clear_log

    assert_empty Trebuchet::Logger::RECORDS
  end

end
