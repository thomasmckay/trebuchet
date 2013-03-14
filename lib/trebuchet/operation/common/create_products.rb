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
      class CreateProducts < Trebuchet::Engine::KatelloCommand
        include Trebuchet::Engine::MultiOperationComponent

        def katello_commands
          @org = @config[:org]
          @config[:product_count].times.collect do |prod_count|
            create_product(prod_count)
          end.flatten
        end

        def create_product(number)
          commands = []
          prod_name = "TestProduct-#{number}"
          commands << { :id=>:product_create,
            :command=>"product create --org=#{esc(@org)} --provider=#{esc(@org)} --name=#{prod_name}"}

          calc_count(@config[:repos_per_product]).times.each do |repo_count|
            repo_name = name = "Repo-#{repo_count}"
            commands << create_repo(prod_name, repo_name)
            commands << sync_repo(prod_name, repo_name) if @config[:sync?]
          end
          commands
        end

        def create_repo(prod_name, name)
          { :id=>:repo_create,
            :command=>"repo create --org=#{esc(@org)} --product=#{prod_name} --name=#{name} " +
                "--url=#{@config[:repo_urls].sample}"}
        end

        def sync_repo(prod_name, repo_name)
          [{ :id=> "sync_repo_#{esc(repo_name)}",
            :command => "repo synchronize --org=#{esc(@org)} --product=#{esc(prod_name)} --name=#{esc(repo_name)}" }]
        end


        def required_configs
          [:org, :environments, :sync?,
            :product_count, :repos_per_product, :repo_urls]
        end

      end
    end
  end
end
