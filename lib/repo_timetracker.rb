require_relative "repo_timetracker/version"
require_relative "repo_timetracker/repo_timeline"

module RepoTimetracker
  class << self
    def record(event_string, directory)
      repo_timeline = RepoTimeline.load_or_initialize_for(directory)

      if repo_timeline.nil?
        'no repo'
      else
        repo_timeline.add_event(event_string)
        repo_timeline.watch_for_file_change_events
      end
    end

    def current_commit_time(directory)
      repo_timeline = RepoTimeline.load_or_initialize_for(directory)
      
      if repo_timeline.nil?
        'no repo'
      else
        time = repo_timeline.current_commit_time
        Time.at(time).utc.strftime("%H:%M:%S")
      end
    end

    def project_time(directory)
      repo_timeline = RepoTimeline.load_or_initialize_for(directory)

      if repo_timeline.nil?
        'no repo'
      else
        time = repo_timeline.project_time
        Time.at(time).utc.strftime("%H:%M:%S")
      end
    end
  end
end
