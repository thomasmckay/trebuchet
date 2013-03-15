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
        validate_config
      end

      def validate_config
        return if !self.respond_to?(:required_configs)
        keys = self.required_configs + [:host, :username, :password]
        missing = keys.collect{|s| s.to_s} - @config.keys.collect{|s| s.to_s}
        raise "Missing configurations values: #{missing.join(', ')}" if !missing.empty?
      end

      def debrief= brief
        @debrief = brief
      end

      def save_debrief
        @debrief.save if @debrief
      end

      def run
        raise NotImplementedError
      end

      def run_command(entry, command)
        time_command(entry) do
          entry.input   = command
          entry.success = system(command)
          print entry.input + "\n" if !entry.success
        end
        save_debrief
      end

      def time_command(entry, &block)
        start_time = Time.now
        yield
        end_time = Time.now

        entry.start_time  = start_time.to_f
        entry.duration    = (end_time - start_time).to_f

        Trebuchet::Logger.log_entry(entry)
      end

      #translates a count which can either be a number or a range [1,100]
      #  if it is a range, returns a random value in that range
      def calc_count(count)
        count = (count[0] +  rand(count[1])) if count.is_a? Array
        count
      end
    end
  end
end
