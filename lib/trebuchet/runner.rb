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

require 'active_support/core_ext/string/inflections' #required for .camelize

module Trebuchet
  class Runner

    # Run all operations, or a specific operation
    #
    # @param  [String]                config    the ID of the role
    # @param  [String]                operation_name the single operation to run, otherwise all
    def run(config, operation_name=nil)
      gather_operations.each do |operation|
        if operation_name.nil? || operation_name == operation.name
          operation.new.run
        end
      end
    end

    # List all operation names
    def list_operations
      gather_operations.collect{|o| o.new.name}
    end

    private

    def gather_operations
      files = Dir.glob(File.dirname(__FILE__) + '/operation/*.rb')
      files.collect do |file|
        file = File.basename(file, '.rb')
        eval('Trebuchet::Operation::' + file.camelize)
      end
    end

  end
end