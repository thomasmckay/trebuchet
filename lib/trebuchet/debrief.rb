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

require 'json'


module Trebuchet
  class Debrief

    @@data_dir = "data/debriefs/"

    def self.data_dir=(path)
      @@data_dir = path
    end

    def initialize(metadata={})
      @metadata = metadata
      create_operation_directory
      @filename = filename
    end

    def save
      File.open([@@data_dir, @metadata[:operation], '/', @filename].join, "w+") do |file|
        file.write(JSON.generate(@metadata.merge({ :data => format_entries })))
      end
    end

    def create_operation_directory
      if !File.directory?(@@data_dir + @metadata[:operation])
        Dir.mkdir(@@data_dir + @metadata[:operation])
      end
    end

    def filename
      timestamp = Time.now.strftime('%Y_%m_%d_%H%M%S')
      [@metadata[:operation], '_', timestamp, '_', @metadata[:name], '.json'].join
    end

    def format_entries
      entries = Trebuchet::Logger::RECORDS[@metadata[:operation]]
      entries.nil? ? [] : entries.map(&:to_hash)
    end

  end
end
