require './lib/trebuchet'

class Trebuchet < Thor
  
  desc "siege OPERATION", "Run one of the available operations scenarios and collect data"
  method_option :username, :aliases => '-u', :desc => "Username for the host targeted", :required => true
  method_option :password, :aliases => '-p', :desc => "Password for the host targeted", :required => true
  method_option :host,     :aliases => '-h', :desc => "Host of the targeted server", :required => true
  def siege(operation)
    engine = ::Trebuchet::Runner.new
    puts "Beginning siege of Katello using #{operation}"
    engine.run(options, operation)
  end

  desc "operations", "List operations available for performing a siege"
  def operations
    runner = ::Trebuchet::Runner.new
    puts "\n"
    puts "Operations Available for Deployment:"
    puts "\n"
    runner.gather_operations.each { |op| puts "        #{op.name} - #{op.description}        " }
    puts "\n"
  end

end
