require 'minitest/autorun'
require "timecop"
require_relative '../lib/repo_timetracker/repo_timeline'

# redefining this method so that test_app 
# folder will be used instead of the real repo_timetracker repo
class RepoTimeline
  def self.find_in_or_above(directory)
    './spec/test_app'
  end
end

class RepoTimeline
  def watch_for_file_change_events
    # Disabled for testing because forking screws with tests running
  end
end


describe RepoTimeline do
  before(:each) do
    Timecop.return
    clear_test_app_timeline_folder
    @repo_timeline = RepoTimeline.new('./spec/test_app')
  end

  describe "current_commit_time" do
    it 'should return zero if no data' do

      @repo_timeline.current_commit_time
    end
  end

  it 'should return no time spent if only one event recorded' do
    @repo_timeline.add_event('event')
    @repo_timeline.current_commit_time.must_equal 0
    @repo_timeline.project_time.must_equal 0
  end

  it 'should return sum of time differences of all recorded events under 30min apart' do
    Timecop.freeze(Time.now)
    @repo_timeline.add_event('event 1')

    Timecop.freeze(Time.now + 30)
    @repo_timeline.add_event('event 2')
    @repo_timeline.current_commit_time.must_equal 30
    @repo_timeline.project_time.must_equal 30

    Timecop.freeze(Time.now + 30)
    @repo_timeline.add_event('event 3')
    @repo_timeline.current_commit_time.must_equal 60
    @repo_timeline.project_time.must_equal 60
    
    Timecop.freeze(Time.now + 30*60)
    @repo_timeline.add_event('event 4')
    @repo_timeline.current_commit_time.must_equal 60
    @repo_timeline.project_time.must_equal 60
    
    Timecop.freeze(Time.now + 29*60)
    @repo_timeline.add_event('event 5')
    @repo_timeline.current_commit_time.must_equal 30*60
    @repo_timeline.project_time.must_equal 30*60
  end

  describe "when a commit happens" do
    before(:each) do
      @repo_timeline = RepoTimeline.new('./spec/test_app')

      Timecop.freeze(Time.now)
      @repo_timeline.add_event('event 1')
      Timecop.freeze(Time.now + 30)
      @repo_timeline.add_event('event 2')
      Timecop.freeze(Time.now + 30)
      @repo_timeline.add_event('event 3')
      Timecop.freeze(Time.now + 29*60)
      @repo_timeline.add_event('event 4')
    end

    it "should return time in new commit only" do
      Timecop.freeze(Time.now + 5*60)
      @repo_timeline.add_event('git commit "commit message"')
      @repo_timeline.current_commit_time.must_equal 0
      @repo_timeline.project_time.must_equal 35*60

      Timecop.freeze(Time.now + 5*60)
      @repo_timeline.add_event('event 6"')
      @repo_timeline.current_commit_time.must_equal 5*60
      @repo_timeline.project_time.must_equal 40*60

    end
  end

  describe "when an amend happens" do
    before(:each) do
      Timecop.freeze(Time.now)
      @repo_timeline.add_event('event 1')
      Timecop.freeze(Time.now + 30)
      @repo_timeline.add_event('event 2')
      Timecop.freeze(Time.now + 30)
      @repo_timeline.add_event('event 3')
      Timecop.freeze(Time.now + 29*60)
      @repo_timeline.add_event('event 4')
      Timecop.freeze(Time.now + 5*60)
      @repo_timeline.add_event('git commit "commit message"')
    end

    it "should return time in new commit only" do
      Timecop.freeze(Time.now + 5*60)
      @repo_timeline.add_event('event 6"')
      @repo_timeline.current_commit_time.must_equal 5*60
      @repo_timeline.project_time.must_equal 40*60

      Timecop.freeze(Time.now + 5*60)
      @repo_timeline.add_event('git commit --amend"')
      @repo_timeline.current_commit_time.must_equal 0
      @repo_timeline.project_time.must_equal 45*60
    end
  end
end