require_relative ''

module FileChangeReporting

  def kill_reporter_daemons
    timetracker_process_pids.each do |pid|
      Process.kill("HUP", pid) if is_not_current_process(pid)
    end
  end

  def become_reporter_daemon(directory)
    if defined? Process.daemon
      Process.daemon
      
      FileWatcher.new([@repo_directory]).watch do |filename|
        RepoTimeline.add_event "File changed: #{filename.slice(/[^\/]+$/)}"
      end
    end
  end


  private

  def is_not_current_process(pid)
    pid != Process.pid
  end

  def timetracker_process_pids
    processes = `ps -ax | grep ruby.*rpt rec`.split("\n")
    processes_without_that_grep = processes.select { |p| not p.include? 'grep' }

    processes_without_that_grep.map { |p| pid_from_string(p) }
  end

  def pid_from_string(process_string)
    pid_string = process_string.match(/\d+/)[0]
    Integer(pid_string)
  end
end