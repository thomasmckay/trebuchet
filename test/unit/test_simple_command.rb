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


require 'rubygems'
require 'minitest/autorun'
require 'trebuchet'

class TestSimpleCommand < MiniTest::Unit::TestCase

  def setup
    Trebuchet::Logger.clear_log
  end

  def test_ls
    op = 'Foo'
    cmd = Trebuchet::Engine::KatelloCommand.new
    entry = Trebuchet::Entry.new({:operation=>op, :name=>'bar'})
    cmd.run_command(entry, 'ls /tmp')

    logs =  Trebuchet::Logger.dump_log
    assert_equal logs.size, 1 #single operation
    assert_equal logs[op].size, 1 #single run in the operation
    entry =  logs[op][0]
    assert_equal entry.name, 'bar'
    assert entry.success
  end

  def test_failure
    op = 'Foo'
    cmd = Trebuchet::Engine::KatelloCommand.new
    entry = Trebuchet::Entry.new({:operation=>op, :name=>'bar'})
    cmd.run_command(entry, 'ls /bad_directory')
    logs =  Trebuchet::Logger.dump_log
    assert !entry.success
  end

end
