require_relative 'job_manager'
require_relative 'job_stack'
require 'rufus-scheduler'

module GymWebcrawler
  class Scheduler
    attr_accessor :logger, :scheduler, :job_stack, :job_manager

    ADVANCE_PERIOD = 2*24*60*60 # 2 days

    def initialize logger
      @logger = logger
      @scheduler = Rufus::Scheduler.new
      @job_stack = JobStack.new
      @job_manager = JobManager.new(@logger, @job_stack)
    end

    def perform
      align_scheduler

      set_daily_task
      set_logging_task
      set_job_manager_task

      start_scheduler!
    end

    # Create jobs to current day
    def align_scheduler
      today = get_numeric_day
      days = [ today, today+1, today+2 ]
      days.each do |day|
        create_and_schedule_jobs day
      end
      schedule_jobs
    end

    def set_job_manager_task
      scheduler.every '5m', first: :now do
        perform_due_jobs
      end
    end

    private

      def perform_due_jobs
        if job_stack.due_jobs.any?
          logger.job_manager_perform_message job_stack
          job_manager.perform_jobs job_stack.due_jobs
        else
          logger.job_manager_no_due_jobs_message job_stack
        end
      end

      def schedule_jobs
        job_stack.jobs
      end

      def set_daily_task
        # Daily at 12.01AM
        # NB: Jobs are created 2 days before their date as classes become bookable 2 days prior
        job = scheduler.schedule '1 0 * * *' do
          day = get_advance_numeric_day
          create_and_schedule_jobs day if is_bookable_day? day
        end
      end

      def create_and_schedule_jobs day
        job_manager.create_jobs_for_day day
      end

      def set_logging_task
        logger.logger_task_start_message
        scheduler.every '30s' do
          logger.logger_short_message job_stack
        end
      end

      def start_scheduler!
        logger.scheduler_start_message
        scheduler.join
      end

      def is_bookable_day? day
        case day
        when 'monday', 1, 'wednesday', 3, 'thursday', 4, 'saturday', 6
          true
        else
          false
        end
      end

      def get_numeric_day
        Time.now.wday
      end

      def get_advance_numeric_day
        today = get_numeric_day

        # Timetable becomes bookable 2 days in advance
        advance_duration = 2

        case get_numeric_day
        when 6
          1
        when 7
          2
        else
          today + advance_duration
        end
      end
  end
end
