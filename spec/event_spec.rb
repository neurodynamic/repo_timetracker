require 'minitest/autorun'
require 'timecop'
require_relative "../lib/repo_timetracker/event"
require_relative "spec_helper"

describe Event do
  before(:each) do
    Timecop.return
  end

  describe 'new' do
    it 'should create a new event' do
      Timecop.freeze
      event = Event.new('test event')

      event.string.must_equal 'test event'
      event.time_recorded.must_equal Time.now
    end

    it 'should set following_time_spent if specified' do
      event = Event.new('test event', :not_working)

      event.following_time_spent.must_equal :not_working
    end

    it 'should set following_time_spent to :working if not specified' do
      event = Event.new('test event')

      event.following_time_spent.must_equal :working
    end
  end

  describe 'following_time_spent_working?' do

    it 'should return true if :working' do
      Event.new('test event', :working).following_time_spent_working?.must_equal true
    end

    it 'should return false if :not_working' do
      Event.new('test event', :not_working).following_time_spent_working?.must_equal false
    end
  end

  describe '==' do
    before(:each) do
      @event = Event.new('test event')
    end

    it 'should return true if all attributes equal' do
      @event.must_equal @event.dup
    end

    it 'should return false if any attributes inequal' do
      @event.wont_equal Event.new('different test event')

      @different_time_event = @event.dup
      @different_time_event.time_recorded = 
      @different_time_event.time_recorded + 5

      @event.wont_equal @different_time_event

      @different_time_event = @event.dup
      @different_time_event.following_time_spent = :not_working
      @event.wont_equal @different_time_event
    end

    describe 'following_time_spent_working?' do

      it 'should return true if :working' do
        Event.new('test event', :working).following_time_spent_working?.must_equal true
      end

      it 'should return false if :not_working' do
        Event.new('test event', :not_working).following_time_spent_working?.must_equal false
      end
    end
  end
end