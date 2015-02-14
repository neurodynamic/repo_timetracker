require 'filewatcher'
require 'fileutils'
require_relative 'repo_timeline_class'
require_relative 'commit_record'

class RepoTimeline

  def initialize(repo_directory)
    @repo_directory = repo_directory.sub(/\/$/, '') #no trailing slash
    @project_name = @repo_directory.slice(/[^\/]*$/)

    @timeline_directory = initialize_timeline_directory_for(@repo_directory)
    @commit_records = load_commit_records
  end

  def add_event(event_string)
    case event_string
    when /git commit --amend/
      amend(event_string)
      
    when /git commit/
      commit(event_string)
      
    else
      staging.generate_new_event(event_string)
    end
  end

  def current_commit_time
    staging.total_time
  end

  def project_time
    time = 0
    @commit_records.inject(0) { |total_time, cr| 
      total_time + cr.total_time
    }
  end

  def watch_for_file_change_events
    if defined? Process.daemon
      kill_previous_commit_timeline_process
      
      Process.daemon
      
      FileWatcher.new([@repo_directory]).watch do |filename|
        staging.generate_new_event("File changed: #{filename.slice(/[^\/]+$/)}")
      end
    end
  end



  private

  def commit(event_string)
    staging.generate_new_event(event_string)

    @commit_records << CommitRecord.create(
                                            @repo_directory, 
                                            event_string
                                            )
  end

  def amend(event_string)
    last_completed_commit.add_events(staging.get_tail)
    last_completed_commit.generate_new_event(event_string)

    staging.clear_events
    staging.generate_new_event(event_string)
  end

  def staging
    if @commit_records.empty?
      @commit_records << CommitRecord.create(@timeline_directory)
    else
      @commit_records.last
    end
  end

  def last_completed_commit
    @commit_records[-2]
  end

  def load_commit_records
    if commit_file_paths.empty?
      CommitRecord.create(@repo_directory)
    end

    commit_file_paths.map { |p| CommitRecord.load(p) }
  end

  def initialize_timeline_directory_for(repo_directory)
    timeline_directory = "#{repo_directory}/.repo_timeline"
    gitignore_path = "#{repo_directory}/.gitignore"
    
    ensure_gitignored(gitignore_path)
    FileUtils.mkdir_p(timeline_directory) unless File.directory?(timeline_directory)

    timeline_directory
  end

  def ensure_gitignored(gitignore_path)
    FileUtils.touch(gitignore_path)

    unless File.readlines(gitignore_path).grep(/\.repo_timeline/).any?
      `echo '\n.repo_timeline' >> #{gitignore_path}`
    end
  end

  def commit_file_paths
    dir_filenames = Dir.entries(@timeline_directory)
    commit_filenames = dir_filenames.select { |f| f.include? '__commit__' }
    commit_filenames.map { |fn| "#{@timeline_directory}/#{fn}" }
  end
  
  def kill_previous_commit_timeline_process
    similar_processes = `ps -ax | grep ruby.*repo_timetracker/bin/rpt`.split("\n")

    if previous_commit_timeline_process = similar_processes.find { |p| not p.include? 'grep' }
      previous_commit_timeline_pid = previous_commit_timeline_process.match(/\d+/)[0]
      if previous_commit_timeline_pid != Process.pid.to_s 
        Process.kill("HUP", Integer(previous_commit_timeline_pid))
      end

    end
  end
end
