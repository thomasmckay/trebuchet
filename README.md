# Trebuchet

[![Build Status](https://secure.travis-ci.org/Katello/trebuchet.png)](http://travis-ci.org/Katello/trebuchet)

For in-depth class and method documentation: http://katello.github.com/trebuchet/

## Goals

* Provide repeatable test scripts for performance benchmarking over time
* Collect historical data of test runs and scenarios
* Allow definable test scenarios separate from test runner

## Installation

Currently Trebuchet must be used via:

    git clone git://github.com/Katello/trebuchet.git
    
## Setup
1. It is highly recommended you use rvm with jruby with trebuchet, see https://rvm.io/ for installating rvm:

    yum install openssl-devel readline-devel java-1.6.0-openjdk     
    curl -L https://get.rvm.io | bash -s stable     
    source ~/.rvm/scripts/rvm # or /usr/local/rvm/scripts/rvm if installed as root   
    
    rvm install jruby-1.7.3     
    rvm use jruby-1.7.3     
    rvm gemset use trebuchet --create 
     
2. Once rvm is setup, go into the trebuchet git repo and run:    

    bundle install

3. If performing any tests that require a working manifest (such as the content performance test), place your manifest in ./data/manifest.zip

## Terminology

* Engine - defines how to run operations against a specific interface (e.g. Katello CLI engine)
* Operation - a pre-defined set of actions to perform against a Katello server that inherits from an engine
* Siege - when an operation is performed with relevant configuration options

## Command Interface

In order to begin running operations and sieging your Katello for performance data, a command line interface is provided using Thor.
To see a list of all commands:

    thor trebuchet:help

To see a list of all operations:

    thor trebuchet:operations

An operation is deployed via a siege and can be done so by:

    thor trebuchet:siege <operation_name> -u <username> -p <password> -h <hostname> --config=./config/file.config

## Example Operations

Simple ping operation:

    thor trebuchet:siege ping  --host=localhost  -u admin -p admin  -n ping

Mass System Registration (Edit options in ./config/MassSystemRegistration.conf):

    thor trebuchet:siege MassSystemRegistration  --host=HOSTNAME  -u admin -p admin  -n SystemRegister --config=./config/MassSystemRegistration.conf --cleanup=false 

Full Population (Edit options in ./config/FullPopulation.conf)

    thor trebuchet:siege FullPopulation  --host=HOSTNAME  -u admin -p admin  -n SystemRegister --config=./config/FullPopulation.conf

## Operation Definitions

Operations are defined by creating a class that inherits from an appropriate engine.

Available Engines:

  * KatelloCommand - runs using the Katello CLI.

The example operation shown below is for a simple Organization create and delete:

    module Trebuchet
      module Operation
        class Organization < Trebuchet::Engine::KatelloCommand

          ORG_NAME = "SomeOrg"
          ENV_NAME = "DEV"

          def name
            "Organization"
          end

          def description
            "Creates and deletes an organization"
          end

          def katello_commands
            [  
                { :id=> :org_create,
                  :command => "org create --name=#{ORG_NAME}" },
                { :id=>:env_create,
                  :command=>"environment create --org=ACME_Corporation --name=#{ORG_NAME} --prior=Library"},
                { :id=> :org_destroy,
                  :command => "org delete --name=#{ORG_NAME}" }
            ]
          end

        end
      end
    end


### Test Types

## Historical Data

## Acquiring Hardware Information

## Testing

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Ensure all tests are passing
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
