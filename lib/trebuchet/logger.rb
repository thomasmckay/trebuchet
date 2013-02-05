


class Trebuchet::Logger


  RECORDS = {}

  def self.log_entry(entry)
    RECORDS[entry.operation] ||= []
    RECORDS[entry.operation]<< entry
  end

  def self.dump_log
    RECORDS
  end

end