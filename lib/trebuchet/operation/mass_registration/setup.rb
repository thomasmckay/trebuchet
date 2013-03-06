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
    module MassRegistration
      class Setup < Trebuchet::Engine::KatelloCommand
        include Trebuchet::Engine::MultiOperationComponent

        def katello_commands
          commands = [
                      { :id=> :org_create,
                        :command => "org create --name=#{esc(@org)}" }
                    ]

          @environments.each do |env|
            commands += [{ :id=>"env_#{env}_create",
                        :command=>"environment create --org=#{esc(@org)} --name=#{esc(env)} --prior=Library"}]
          end
          commands
        end

        def set_params(params)
          @org = params[:org]
          @environments = params[:environments]
        end

        def esc(string)
          "\"#{string}\""
        end

      end
    end
  end
end
