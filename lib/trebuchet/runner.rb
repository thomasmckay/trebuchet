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
require 'active_support/core_ext/hash' #with_indifferent_access

module Trebuchet
  class Runner

    @@operations_location = File.dirname(__FILE__) + '/operation/*.rb'

    def self.operations_location=(path)
      @@operations_location = path
    end

    # Run all operations, or a specific operation
    #
    # @param  [Hash]    config          config hash to pass to operations (currently  :host, :user, :password)
    # @param  [String]  operation_name  the single operation to run, otherwise all
    def run(config, operation_name=nil)
      config = config.with_indifferent_access

      gather_operations.each do |operation|
        if operation_name.nil? || operation_name == operation.name
          operation.new(config).run
        end
      end
    end

    # List all operations
    # 
    # @return [Array] list of available operations to deploy
    def list_operations
      gather_operations.collect{ |op| op.name }
    end

    def gather_operations
      files = Dir.glob(@@operations_location)
      files.collect do |file|
        file = File.basename(file, '.rb')
        get_operation(file)
      end
    end

    def get_operation(name)
      Trebuchet::Operation.const_get(name.camelize)
    end

  end
end
