require 'yaml'
require_relative "commit_record_class"

class CommitRecord
  require_relative 'event'

  attr_accessor :events, :file_path

  A_LONG_TIME = 30*60 # 30 minutes

  def initialize(project_directory, first_event_string = nil)
    @project_name = project_directory.slice(/[^\/]*$/)
    @timeline_directory = "#{project_directory}/.repo_timeline"
    @file_path = generate_file_path(project_directory)

    @events = []
    @events << Event.new(first_event_string) if first_event_string
  end

  def generate_new_event(event_string, following_time_spent = :working)
    @events << Event.new(event_string, following_time_spent)
    @events[-2].following_time_spent = :not_working if long_after_previous_event?(@events[-1])
    save
  end

  def total_time
    time = 0
    @events.each_cons(2) do |pair|
      time += pair[1].time_recorded - pair[0].time_recorded if pair[0].following_time_spent_working?
    end

    time.round
  end

  def add_events(events)
    @events += events
    save
  end

  def get_tail
    @events[1..-1]
  end

  def clear_events
    @events = []
    save
  end

  def save
    File.open(@file_path, "w") { |f| f.puts YAML::dump(self) }
    self
  end

  def ==(other_commit)
      all_events_equal(other_commit) and 
      @file_path == other_commit.file_path
  end



  private

  def generate_file_path(directory)
    "#{@timeline_directory}/#{generate_file_name}"
  end

  def generate_file_name
    time_string = Time.now.strftime('%y-%m-%d_%Hh%Mm%Ss')
    "#{@project_name}__commit__#{time_string}.yaml"
  end

  def long_after_previous_event?(event)
    index_of_this_event = @events.index(event)

    previous_event = @events[index_of_this_event - 1]

    if previous_event
      time_difference = 
          (event.time_recorded - previous_event.time_recorded).ceil

      time_difference >= A_LONG_TIME
    else
      false
    end
  end

  def all_events_equal(other_commit)
    all_equal = true
    @events.each_with_index do |c, i|
      all_equal = false unless c == other_commit.events[i]
    end
    all_equal
  end
end