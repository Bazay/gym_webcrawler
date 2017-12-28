require_relative 'gym_webcrawler/scheduler'
require_relative 'gym_webcrawler/webcrawler'
require_relative 'gym_webcrawler/scheduler_logger'

module GymWebcrawler
  class Main
    attr_reader :logger, :scheduler, :webcrawler

    def initialize
      # See http://ruby.about.com/od/tasks/a/logger.htm
      @logger = SchedulerLogger.new log_file_path, 'weekly'
      @scheduler = Scheduler.new @logger
      @webcrawler = Webcrawler.new
    end

    def start
      scheduler.perform
    end

    private

      def log_file_path
        File.dirname(__FILE__) + '/../logs/log.txt'
      end
  end
end

GymWebcrawler::Main.new.start
