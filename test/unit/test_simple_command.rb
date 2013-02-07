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


class TestSimpleCommand < MiniTest::Unit::TestCase

  def setup
    @operation = Trebuchet::Operation::SimpleBash.new
    Trebuchet::Logger.clear_log
  end

  def test_ls
    cmd = Trebuchet::Engine::KatelloCommand.new
    entry = Trebuchet::Entry.new({:operation=>@operation.class.name, :name=>'bar'})
    cmd.run_command(entry, 'ls /tmp')

    logs =  Trebuchet::Logger.dump_log
    assert_equal 1, logs.size     #single operation
    assert_equal 1, logs[@operation.class.name].size #single run in the operation

    entry =  logs[@operation.class.name][0]
    assert_equal 'bar', entry.name
    assert       entry.success
  end

  def test_failure
    cmd = Trebuchet::Engine::KatelloCommand.new
    entry = Trebuchet::Entry.new({:operation => @operation.class.name, :name=>'bar'})
    cmd.run_command(entry, 'ls /bad_directory')
    logs =  Trebuchet::Logger.dump_log

    refute entry.success
  end

end
