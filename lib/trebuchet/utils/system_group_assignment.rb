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
require 'rest_client'

module Trebuchet
  module Utils
    class SystemGroupAssignment

      def initialize(config)
        @config = config
      end

      def run(org_id, group_names, system_uuids, groups_per_system)
        @client = RestCalls.new(build_url(@config))
        group_ids = find_groups(org_id, group_names)
        group_allocation = {}
        system_uuids.each do |uuid|
          to_assign = pick_groups(groups_per_system, group_ids)
          to_assign.each do |group_id|
            group_allocation[group_id] ||= []
            group_allocation[group_id] << uuid
          end
        end

        group_allocation.each_pair do |group_id, uuid_list|
          print "Adding #{uuid_list.length} systems to group #{group_id}\n"
          @client.add_to_group(org_id, group_id, uuid_list)
        end

      end

      def find_groups(org_id, names)
        groups = @client.groups(org_id)
        groups.select{|grp| names.include?(grp['name'])}.collect{|grp| grp['id']}
      end

      def pick_groups(count, list)
        found = []
        count.times.each do |num|
          found << (list - found).sample
        end
        found
      end

      def build_url(config)
        url = config[:http] ? "http://" : "https://"
        url += "#{@config[:username]}:#{@config[:password]}@#{@config[:host]}"
        url += ":#{config[:port]}" if config[:port]
        url += "/katello/api"
      end
    end

    class RestCalls
      def initialize(url)
        @url_base = url
      end

      def groups(org_id)
        JSON.parse(RestClient.get("#{@url_base}/organizations/#{org_id}/system_groups/"))
      end

      def add_to_group(org_id, group_id, system_uuids)
        params = {:system_group=>{:system_ids=>system_uuids}}
        JSON.parse(RestClient.post("#{@url_base}/organizations/#{org_id}/system_groups/#{group_id}/add_systems/", params))
      end

    end
  end
end



