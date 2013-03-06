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
    class SystemCreator

      def initialize(count, threads, config)
        @facts = JSON.parse(get_contents(File.join( Trebuchet::DATA_DIR, '/system/facts.json')))
        @pkgs = JSON.parse(get_contents(File.join( Trebuchet::DATA_DIR, '/system/package_profile.json')))
        @count = count
        @threads = threads

        @config = config
      end


      def run(environment, org_id)
        thread_count = @count/@threads
        threads = []

        #for each thread
        @threads.times do |current_thread|
          #create a thread that creates thread_count systems
          threads << Thread.new do
            thread_count.times do
              create_system(environment, org_id)
            end
          end
        end

        #wait for all the threads
        threads.each do |thread|
          thread.join
        end
      end

      def create_system(environment, org_id)

        client = RestCalls.new("https://#{@config['username']}:#{@config['password']}@#{@config['host']}/katello/api")

        env_id = nil
        client.environments(org_id).each do |env_json|
          env_id =  env_json['id'] if env_json['label'] == environment
        end
        raise "Environment not found" if env_id.nil?
        name = "System-#{rand_hex}"
        print "Creating #{name}\n "
        system = client.create_system({
            :name=>name,
            :environment_id=> env_id,
            :organization_id=>org_id,
            :facts=>@facts,
            :cp_type=>'system'
         })
        client.upload_package_profile(system['uuid'], @pkgs)
      end

      def get_contents(filename)
        file = File.open( filename ,'r')
        contents = file.read
        file.close
        contents
      end

      def rand_hex
        #nice, non-secure random hex
        "%08x" % (rand * 0xffffffff)
      end
    end

    class RestCalls
      def initialize(url)
        @url_base = url
      end

      def environments(org_id)
        JSON.parse(RestClient.get("#{@url_base}/organizations/#{org_id}/environments/"))
      end

      def create_system(params)
        JSON.parse(RestClient.post("#{@url_base}/systems/", params))
      end

      def delete_system(uuid)
        JSON.parse(RestClient.delete("#{@url_base}/systems/#{uuid}/"))
      end

      def upload_package_profile(uuid, profile)
        JSON.parse(RestClient.put("#{@url_base}/consumers/#{uuid}/packages/", '_json'=>profile))
      end

    end
  end
end



