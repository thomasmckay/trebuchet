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
#
#
# -= Users CSV =-
#
# Columns
#   Login
#     - Login name of the user.
#     - May contain '%d' which will be replaced with current iteration number of Count
#     - eg. "user%d" -> "user1"
#   Count
#     - Number of times to iterate on this line of the CSV file
#   First Name
#   Last Name
#   Email
#
# -= Systems CSV =-
#
# Columns
#   Name
#     - Name of the system.
#     - May contain '%d' which will be replaced with current iteration number of Count
#     - eg. "system%d" -> "system1"
#   Count
#     - Number of times to iterate on this line of the CSV file
#   Org Label
#     - Organization label; org must already exist.
#   Environment Label
#     - Environment label; environment must already exist.
#   Groups
#     - Comma separated list of groups. Group must already exist.
#     - Feature not implemented yet.
#   Virtual
#     - Value of "Yes" indicates the system is a VM.
#   Host
#     - If "Yes" above, indicates the host system of the VM.
#     - Feature not implemented yet.
#   OS
#     - Operating system name and version
#     - Populates system facts: distribution.name and distribution.version
#     - eg. "6.4" -> "RHEL", "6.4"
#     - eg. "CentOS 6" -> "CentOS", "6"
#   Arch
#     - Populates system fact: uname.machine
#     - eg. "x86_64"
#   Sockets
#     - Populates system fact: cpu.cpu_socket(s)
#   RAM
#     - Populates system fact: memory.memtotal
#     - eg. "16 GB"
#   Cores
#     - Populates system fact: cpu.core(s)_per_socket
#   SLA
#     - Feature not implemented yet.
#   Products
#     - Comma separated list product number and name pairs
#     - Format is <number>|<name>
#     - "70|RHEL Server, 81|JBoss"
#   Subscriptions
#     - Comma separated list subscription number and name pairs
#     - Format is <number>|<name>
#     - "RH01037|RHEL Premium (8 sockets)"
#     - Feature not implemented yet.
#
# Example System CSV
#   Name,Count,Org Label,Environment Label,Groups,Virtual,Host,OS,Arch,Sockets,RAM,Cores,SLA,Products,Subscriptions
#   two%d,2,shippingreceiving,Library,,Yes,four1,RHEL 6.4,x86_64,1,4,1,Standard,"69|Red Hat Enterprise Linux Server,79|Red Hat Enterprise Linux Server",RH0103708|Red Hat Enterprise Linux Server Premium (8 sockets) (Up to 4 guests)
#
# Running
#   % thor trebuchet:siege csv --config ./config/csv.conf
#
# Config File
#  {
#    "threads": 2,
#    "csv": {
#      "systems": "./data/csv/systems.csv"
#    }
#  }
#
module Trebuchet
  module Operation
    class Csv < Trebuchet::Engine::MultiOperation

      def self.name
        "CSV"
      end

      def self.description
        "Data population from CSV files."
      end

      def operation_list
        params = @config

        list = [
          Trebuchet::Operation::Common::TieredCsv,
        ]

        list.collect do |op|
          op.name = self.class.name
          op = op.new(params)
          op
        end
      end

      def required_configs
        [:threads, :csv]
      end

    end

  end
end
