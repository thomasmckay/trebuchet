# Copyright (c) 2013 Red HatV
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


class TestBase < MiniTest::Unit::TestCase

  def setup
    @operation = Trebuchet::Operation::SimpleBash.new
    @entry1 = Trebuchet::Entry.new({ :operation => @operation.class.name, :name => 'step_1' })
    @base = Trebuchet::Engine::Base.new
  end

  def teardown
    Trebuchet::Logger.clear_log
  end

  def test_run
    assert_raises(NotImplementedError) do
      @base.run
    end
  end

  def test_time_command
    @base.time_command(@entry1) do
      puts ""
    end

    refute_empty Trebuchet::Logger::RECORDS
  end

  def test_run_command
    @base.run_command(@entry1, 'echo test_run_command')

    refute_empty Trebuchet::Logger::RECORDS
  end

end
