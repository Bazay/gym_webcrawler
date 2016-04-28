require 'logger'
require_relative 'scheduler'

module GymWebcrawler
  class SchedulerLogger < Logger
    def logger_task_start_message
      info '****************************************************************'
      info "ScheduleLogger task started at #{formatted_datetime}"
    end

    def scheduler_start_message
      info "Scheduler started at #{formatted_datetime}"
    end

    def job_manager_perform_message job_stack
      info "JobManager performing jobs at #{formatted_datetime}. Due jobs: #{job_stack.due_jobs.count}"
      info "DUE JOBS:"
      display_jobs job_stack.due_jobs
    end

    def job_manager_no_due_jobs_message job_stack
      info "JobManager: No due jobs. Pending job count: #{job_stack.jobs.count}"
      info "PENDING JOBS:"
      display_jobs job_stack.jobs
    end

    def logger_short_message job_stack
      info "Scheduler running at #{formatted_datetime}"
      info "JobStack size: #{job_stack.jobs.count} jobs enqueued."
      if job_stack.jobs.any?
        next_job_time = job_stack.jobs.first.job_at - advance_period
        info "Next job performing #{next_job_time < Time.now ? 'within 5 minutes' : 'at ' + formatted_datetime(next_job_time)}"
      end
    end

    def success_confirmation_for_job job
      info "Successfully booked job at #{formatted_datetime}. Double-check for email confirmation"
      job_info job
    end

    def delete_confirmation_for_job job
      error "Unsuccessful booking for job at #{formatted_datetime}. Job was removed from stack"
      job_info job
    end

    def fail_confirmation_for_job job
      error "Error booking for job at #{formatted_datetime}. Job fail counter increased for job"
      job_info job
    end

    def error_confirmation_for_weekend_job job
      error "Error booking for job at #{formatted_datetime}. Is a 'weekend job' so nothing was done"
      job_info job
    end

    def webcrawler_error_message error
      error "!!!Webcrawler failed at #{formatted_datetime}!!! Reason: #{error}"
    end

    private

      def formatted_datetime datetime = nil
        datetime.nil? ? Time.now.strftime('%d/%b/%Y %l:%M%p') : datetime.strftime('%d/%b/%Y %l:%M%p')
      end

      def display_jobs jobs
        line
        jobs.each do |job|
          job_info job
        end
        info "No jobs" if jobs.empty?
      end

      def job_info job
        info "ID: #{job.id} due at #{formatted_datetime}"
        info "Description: #{job.name}, #{job.start_time} on #{day_name_from_numeric(job.day)}"
        info "Try count: #{job.try_count}"
        info "Errors: #{job.errors.uniq.join(', ')}"
        line
      end

      def line
        info "----------------------------------------------------------------"
      end

      def day_name_from_numeric day_number
        Date::DAYNAMES[day_number]
      end

      def advance_period
        Scheduler::ADVANCE_PERIOD
      end
  end
end
