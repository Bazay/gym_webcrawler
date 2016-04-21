require_relative 'gym_webcrawler/scheduler'
require_relative 'gym_webcrawler/webcrawler'
require_relative 'gym_webcrawler/scheduler_logger'

module GymWebcrawler
  class Main
    attr_reader :logger, :scheduler, :webcrawler

    def initialize
      # See http://ruby.about.com/od/tasks/a/logger.htm
      @logger = SchedulerLogger.new 'logs/log.txt', 'weekly'
      @scheduler = Scheduler.new @logger
      @webcrawler = Webcrawler.new
    end

    def start
      scheduler.perform
    end
  end
end

GymWebcrawler::Main.new.start
