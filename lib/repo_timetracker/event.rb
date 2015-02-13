class Event
  attr_accessor :string, :time_recorded, :following_time_spent 

  def initialize(string, following_time_spent = nil)
    @string = string
    @time_recorded = Time.now
    @following_time_spent = following_time_spent || :working
  end

  def following_time_spent_working?
    following_time_spent == :working
  end

  def ==(other_event)
    @string == other_event.string and 
    @time_recorded == other_event.time_recorded and 
    @following_time_spent == other_event.following_time_spent
  end
end