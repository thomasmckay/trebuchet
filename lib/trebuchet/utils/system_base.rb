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
    class SystemBase

      def initialize(threads, config)
        @threads = threads
        @config = config
      end

      def get_contents(filename)
        file = File.open( filename ,'r')
        contents = file.read
        file.close
        contents
      end

      def get_lines(filename)
        file = File.open( filename ,'r')
        contents = file.readlines
        file.close
        contents
      end

      def rand_hex
        #nice, non-secure random hex
        "%08x" % (rand * 0xffffffff)
      end

      def build_url(config)
        url = config[:http] ? "http://" : "https://"
        url += "#{@config[:username]}:#{@config[:password]}@#{@config[:host]}"
        url += ":#{config[:port]}" if config[:port]
        url += config[:api] ? config[:api] : "/katello/api"
      end
    end

    class RestCalls
      def initialize(url)
        @url_base = url
      end

      def parameterize(params)
        parameters = nil
        params.each do |key,value|
          if parameters.nil?
            parameters = '?'
          else
            parameters += '&'
          end
          parameters += "#{key}=#{value}"
        end
        parameters
      end

      def environments(org_id)
        JSON.parse(RestClient.get("#{@url_base}/organizations/#{org_id}/environments/"))
      end

      def search_systems(env_id, params)
        JSON.parse(RestClient.get("#{@url_base}/environments/#{env_id}/systems#{parameterize(params)}"))
      end

      def create_system(params)
        JSON.parse(RestClient.post("#{@url_base}/systems/", params))
      end

      def delete_system(uuid)
        JSON.parse(RestClient.delete("#{@url_base}/systems/#{uuid}/"))
      end

      def update_system(uuid, params)
        JSON.parse(RestClient.put("#{@url_base}/systems/#{uuid}", params.to_json, default_headers))
      end

      def upload_package_profile(uuid, profile)
        JSON.parse(RestClient.put("#{@url_base}/consumers/#{uuid}/packages/", {'_json'=>profile}.to_json, default_headers))
      end

      private

      def default_headers
       {
         :content_type => 'application/json',
         :accept       => 'application/json'
       }
      end
    end
  end
end



