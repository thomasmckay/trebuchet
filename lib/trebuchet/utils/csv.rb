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
require 'csv'
require 'trebuchet/utils/api_base'

module Trebuchet
  module Utils
    class Csv < ApiBase

      def initialize(config)
        super(config[:threads], config)
        @users_csv = get_lines(config[:csv][:users])[1..-1] if config[:csv][:users]
        @systems_csv = get_lines(config[:csv][:systems])[1..-1] if config[:csv][:systems]
      end

      def run()
        run_lines(method(:create_users_from_csv), @users_csv) if @users_csv
        #run_lines(method(:create_systems_from_csv), @systems_csv) if @systems_csv
      end

      def run_lines(creator, csv)
        lines_per_thread = csv.length/@threads + 1
        threads = []
        @client = RestCalls.new(build_url(@config))

        @threads.times do |current_thread|
          start_index = ((current_thread) * lines_per_thread).to_i
          finish_index = ((current_thread + 1) * lines_per_thread).to_i
          lines = csv[start_index...finish_index].clone
          threads << Thread.new do
            Thread.current[:systems] = []
            lines.each do |line|
              # First character of '#' means commented line so skip
              if line.index('#') != 0
                creator.call(line)
              end
            end
          end
        end

        # wait for all the threads
        threads.each do |thread|
          thread.join
        end
      end

      def create_users_from_csv(line)
        print "LINE #{line}"

        details = parse_user_csv(line)

        details[:count].times do |number|
          name = namify(details[:name_format], number)
          @client.create(:users, {
                           :user => {
                             :username => name,
                             :email => details[:email],
                             :password => 'admin'
                           }
                         })
        end

      end

      def create_systems_from_csv(line)
        print "LINE #{line}"
        return

        @environments ||= {}

        details = parse_system_csv(line)

        facts = {}
        facts['cpu.core(s)_per_socket'] = details[:cores]
        facts['cpu.cpu_socket(s)'] = details[:sockets]
        facts['memory.memtotal'] = details[:ram]
        facts['uname.machine'] = details[:arch]
        facts['system.certificate_version'] = '3.2'
        if details[:os].index(' ')
          (facts['distribution.name'], facts['distribution.version']) = details[:os].split(' ')
        else
          (facts['distribution.name'], facts['distribution.version']) = ['RHEL', details[:os]]
        end

        details[:count].times do |number|
          name = namify(details[:name_format], number)

          if details[:virtual] == 'Yes'
            facts['virt.is_guest'] = true
            facts['virt.uuid'] = name
          else
            facts['virt.is_guest'] = false
          end

          if @environments[details[:org_label]].nil?
            @client.environments(details[:org_label]).each do |env|
              @environments[details[:org_label]] ||= {}
              @environments[details[:org_label]][env['label']] = env['id']
            end
          end

          systems = @client.search_systems(@environments[details[:org_label]][details[:env_label]],
                                           {:name => name})
          if systems.length == 0
            print "CREATE\n"
            system = @client.create_system(:name => name,
                                           :organization_id => details[:org_label],
                                           :environment_id => @environments[details[:org_label]][details[:env_label]],
                                           :facts => facts,
                                           :cp_type => 'system'
                                           )
          else
            system = systems[0]
          end

          @client.update_system(system['uuid'], {:facts => facts, :installedProducts => details[:products]})

        end
      end

      def namify(name_format, number)
        if name_format.index('%')
          name_format % number
        else
          name_format
        end
      end

      def parse_user_csv(line)
        keys = [:name_format, :count, :first_name, :last_name, :email]
        details = CSV.parse(line).map { |a| Hash[keys.zip(a)] }[0]

        details[:count] = details[:count].to_i

        details
      end

      def parse_system_csv(line)
        keys = [:name_format, :count, :org_label, :env_label, :groups,
                :virtual, :host, :os, :arch, :sockets, :ram,
                :cores, :sla, :products, :subscriptions]
        details = CSV.parse(line).map { |a| Hash[keys.zip(a)] }[0]

        details[:count] = details[:count].to_i

        details[:products] = details[:products].split(',').collect do |product_details|
          product = {}
          (product[:productId], product[:productName]) = product_details.strip.sub('"','').sub('"','').split('|')
          product
        end

        details[:subscriptions] = details[:subscriptions].split(',').collect do |subscription_details|
          subscription = {}
          (subscription[:number], subscription[:name]) = subscription_details.strip.sub('"','').sub('"','').split('|')
          subscription
        end

        details
      end
    end
  end
end



