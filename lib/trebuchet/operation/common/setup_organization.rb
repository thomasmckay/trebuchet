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
      class SetupOrganization < Trebuchet::Engine::KatelloCommand
        include Trebuchet::Engine::MultiOperationComponent

        def katello_commands
          @org = @config[:org]
          @environments = @config[:environments]

          commands = [
                      { :id=> "org_create_#{@org}",
                        :command => "org create --name=#{esc(@org)}" }
                     ]

          @environments.each_with_index do |env, index|
            if index % 3 == 0
              previous = 'Library'
            else
              previous = @environments[index-1]
            end
            commands << { :id=>"env_#{env}_create",
                        :command=>"environment create --org=#{esc(@org)} --name=#{esc(env)} --prior=#{previous}"}
          end
          commands << { :id=>:provider_create,
                              :command=>"provider create --org=#{esc(@org)} --name=#{esc(@org)}"}
          commands
        end

        def required_configs
          [:org, :environments]
        end

      end
    end
  end
end
