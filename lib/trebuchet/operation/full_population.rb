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
    class FullPopulation < Trebuchet::Engine::MultiOperation

      def self.name
        "FullPopulation"
      end

      def self.description
        "Does a large scale population of katello accross all content types."
      end

      def operation_list
        @config[:organization_count].times.collect do |org_count|
          org_operation_list("BulkLoadOrg_#{rand(10000)}")
        end.flatten
      end

      def org_operation_list(org_name)
        params = {
            :host => @config[:host],
            :username => @config[:username],
            :password => @config[:password],
            :name => @config[:name],
            :org => org_name,
            :threads => @config[:threads],
            :environments =>environment_list(@config[:environments_per_org]),
            :system_count =>calc_count(@config[:systems_per_org]),
            :product_count=>calc_count(@config[:products_per_org]),
            :repos_per_product   =>@config[:repos_per_product],
            :repo_urls    =>@config[:repo_urls],
            :sync?         =>@config[:sync?],
            :group_names  => @config[:system_groups_per_org].times.collect{|count| "Group-#{count}"}
        }

        @config[:system_groups] = params[:group_names]
        org_op_list = [Trebuchet::Operation::Common::SetupOrganization.new(params),
                       Trebuchet::Operation::Common::CreateProducts.new(params),
                       Trebuchet::Operation::Common::CreateSystemGroups.new(params),
                       Trebuchet::Operation::Common::SimpleSystemRegistration.new(params)]

        org_op_list.collect do |op|
          op.class.name = self.class.name
          op
        end
      end

      def environment_list(count)
        calc_count(count).times.collect do |env_count|
          "#{['Dev', 'Prod', 'QA', 'Stage'].sample}-#{env_count}"
        end
      end


      def required_configs
        [:organization_count, :products_per_org,
          :repos_per_product, :systems_per_org, :environments_per_org,
          :repo_urls, :sync?, :system_groups_per_org]
      end

    end
  end
end
