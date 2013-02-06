require './lib/trebuchet'

class Trebuchet < Thor
  
  desc "siege OPERATION", "Run one of the available operations scenarios and collect data"
  def siege(operation)
    engine = ::Trebuchet::Runner.new
    puts "Beginning siege of Katello using #{operation}"
    engine.run({}, operation)
  end

  desc "operations", "List operations available for performing a siege"
  def operations
    runner = ::Trebuchet::Runner.new
    puts "\n"
    puts "Operations Available for Deployment:"
    puts "\n"
    runner.list_operations.each { |op| puts "        #{op.name} - #{op.description}        " }
    puts "\n"
  end

end
