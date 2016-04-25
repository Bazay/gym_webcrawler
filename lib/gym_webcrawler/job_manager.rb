require 'date'
require_relative 'job_definitions'
require_relative 'webcrawler'

module GymWebcrawler
  class JobManager < Struct.new(:logger, :job_stack)
    attr_accessor :webcrawler

    def initialize *args
      super
      @webcrawler = Webcrawler.new(self.logger)
    end

    def create_jobs_for_day day
      job_definer = JobDefinitions.new(day)
      defined_jobs = job_definer.jobs_for_day
      defined_jobs.each do |job|
        job_stack.add_job job_stack.build_job job unless job[:job_at] - 60 < Time.now # Don't add already expired jobs
      end
      # Need to check return type here
    end

    def perform_jobs jobs
      begin
        handle_responses webcrawler.perform jobs
      rescue => error
        logger.webcrawler_error_message error
      end
    end

    def handle_responses responses
      responses.each do |response|
        case response.action
        when 'delete'
          response.job.errors << response.message unless response.job.errors.include? response.message
          unless is_weekend?
            logger.delete_confirmation_for_job response.job
            job_stack.remove_job response.job
          else
            logger.error_confirmation_for_weekend_job
          end
        when 'fail'
          unless is_weekend?
            job_stack.fail_job! response.job, response.message
            logger.fail_confirmation_for_job response.job
          else
            logger.error_confirmation_for_weekend_job
          end
        when 'success'
          logger.success_confirmation_for_job response.job
          job_stack.remove_job response.job
        end
      end
    end

    private

      def is_weekend?
        today = Date.today
        today.saturday? || today.sunday?
      end
  end
end
