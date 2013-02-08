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


module Trebuchet
  module Engine
    class Base

      def initialize(config={})
        @config   = config
        @debrief  = Trebuchet::Debrief.new({ :operation => self.class.name })
      end

      def run
        raise NotImplementedError
      end

      def run_command(entry, command)
        time_command(entry) do
          entry.input   = command
          entry.success = system(command)
        end
      end

      def time_command(entry, &block)
        start_time = Time.now
        yield
        end_time = Time.now

        entry.start_time  = start_time.to_f
        entry.duration    = (end_time - start_time).to_f

        Trebuchet::Logger.log_entry(entry)
      end

    end
  end
end
