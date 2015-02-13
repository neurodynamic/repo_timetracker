require 'minitest/autorun'
require 'timecop'
require 'yaml'
require_relative "../lib/repo_timetracker/commit_record"
require_relative "spec_helper"

describe CommitRecord do
  before(:each) do
    Timecop.return
    @app_folder = "./spec/test_app"
    FileUtils::mkdir_p "#{@app_folder}/.repo_timeline" unless File.directory?("#{@app_folder}/.repo_timeline")

    clear_test_app_timeline_folder
  end

  describe "new" do
    it "should create a new commit with no events if no event string given" do
      CommitRecord.new(@app_folder).events.any?.must_equal false
    end

    it "should create a new commit with a events if event string given" do
      CommitRecord.new(@app_folder, 'bangin_event').events.length.must_equal 1
    end

    it "should set file_path based on project name and time" do
      Timecop.freeze(Time.now) do
        commit = CommitRecord.new(@app_folder, 'overzealous_event')
        commit.file_path.must_equal "#{@app_folder}/.repo_timeline/test_app__commit__#{Time.now.strftime('%y-%m-%d_%Hh%Mm%Ss')}.yaml"
      end
    end
  end

  describe "generate_new_event" do
    before(:each) do
      @commit = CommitRecord.new(@app_folder)
    end

    it "should add a new event" do
      @commit.events.must_be :empty?

      @commit.generate_new_event 'awesome_event'

      @commit.events.length.must_equal 1
      @commit.events.last.string.must_equal 'awesome_event'
    end

    it "should set previous event to :not_working if event issued 30+ min after previous event" do
      @commit.generate_new_event 'cool_event'

      Timecop.freeze(Time.now + 30*60) do
        @commit.generate_new_event 'much_later_event_that_is_still_cool'
      end

      @commit.events.first.following_time_spent.must_equal :not_working
    end

    it "should NOT set previous event to :not_working if less than 30min time difference" do
      @commit.generate_new_event 'cool_event'

      Timecop.freeze(Time.now + 30*60 - 2) do
        @commit.generate_new_event 'temporally_proximitous_event'
      end

      @commit.events.first.following_time_spent.must_equal :working
    end
  end

  describe "total_time" do
    before(:each) do
      @commit = CommitRecord.new(@app_folder)
    end

    it "should return zero if no events in commit" do
      @commit.total_time.must_equal 0
    end

    it "should return zero if only one event in commit" do
      @commit.generate_new_event('sad_event')
      @commit.total_time.must_equal 0
    end

    it "should total time between all event pair intervals of less than 30 minutes" do
      
      Timecop.freeze(Time.now) do
        @commit.generate_new_event('sad_event')
      end

      Timecop.freeze(Time.now + 25*60) do
        @commit.generate_new_event 'lonely_event'
      end

      Timecop.freeze(Time.now + 60*60) do
        @commit.generate_new_event 'philosophically_confused_event'
      end

      Timecop.freeze(Time.now + 75*60) do
        @commit.generate_new_event 'untrustworthy_event'
      end

      @commit.total_time.must_equal(75*60 - 35*60)
    end
  end

  describe "add_events" do
    it "should add array of events to current events" do
      @commit = CommitRecord.new(@app_folder, 'eventant')

      @commit.events.length == 1
      @commit.add_events([
        Event.new('badly_spelllled_event'),
        Event.new('obsequious_event'),
        Event.new('event_which_must_not_be_named')
        ])

      @commit.events.length.must_equal 4
    end
  end

  describe "get_tail" do
    it "should return tail of events array" do
      @commit = CommitRecord.new(@app_folder, 'coming_up_with_names_for_these_is_hard')

      @commit.get_tail.must_equal []
      @commit.generate_new_event 'oh_well'
      @commit.get_tail.length.must_equal 1
    end
  end

  describe "clear_events" do
    it "should make events array equal to []" do
      @commit = CommitRecord.new(@app_folder, 'blah')
      @commit.events.wont_equal []
      @commit.clear_events
      @commit.events.must_equal []
    end
  end

  describe "==" do
    it "should return true if all events and file_path are equal" do
      Timecop.freeze(Time.now) do
        @commit_1 = CommitRecord.new(@app_folder, 'blah')
        @commit_2 = CommitRecord.new(@app_folder, 'blah')
      end

      @commit_1.must_equal @commit_2
    end

    it "should return false if any events are not equal" do
      Timecop.freeze(Time.now) do
        @commit_1 = CommitRecord.new(@app_folder, 'blah')
        @commit_2 = CommitRecord.new(@app_folder, 'blahblah')
      end

      @commit_1.wont_equal @commit_2
    end

    it "should return false if filepaths are not equal" do
      @commit_1 = CommitRecord.new(@app_folder, 'blah')
      @commit_2 = @commit_1.dup
      @commit_2.file_path = 'fkdlsajfl'

      @commit_1.wont_equal @commit_2
    end
  end

  describe "save" do
    it "should write commit info to yaml file named by file_path variable" do
      file_path = "#{@app_folder}/.repo_timeline/test_save_file.yml"

      @commit = CommitRecord.new(@app_folder, 'blah')
      @commit.file_path = file_path
      @commit.save

      @commit.must_equal YAML::load(IO.read(file_path))
    end
  end
end