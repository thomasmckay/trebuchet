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
  module Operation
    module Common
      class TieredSystemRegistration < Trebuchet::Engine::SystemRegistration
        include Trebuchet::Engine::MultiOperationComponent

        def required_configs
          #optional config :system_groups
          [:org, :environments, :system_count, :threads]
        end

        def run_info
          total_systems = @config[:system_count]
          data_points = 10
          threads = @config[:threads]

          count_per_run = total_systems/data_points

          runs = []
          data_points.times.each do |current_count|
            runs << {:threads=>threads, :count=>count_per_run, :name=>"#{count_per_run} Bulk load ##{current_count+1}"}
            runs << {:threads=>1, :count=>1, :name=>"Create single system after #{(current_count+1)*count_per_run}"}
          end
          runs
        end

        def org_id
          @config[:org]
        end

        def environments
          @config[:environments]
        end

      end
    end
  end
end
