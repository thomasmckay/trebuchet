



class Trebuchet::Entry
  attr_accessor :operation, :name, :duration, :details

  def initialize(params={})
    self.operation = params[:operation]
    self.name = params[:name]
    self.duration = params[:duration]
    self.details = params[:details]
  end
end