require_relative 'job'

module GymWebcrawler
  class JobStack
    attr_accessor :jobs, :job_count

    def initialize
      @jobs = []
      @job_count = 1
    end

    def add_job job
      unless job_exists? job
        job.id = job_count
        jobs << job
        self.job_count += 1
        job
      end
    end

    def build_job options
      Job.new options
    end

    def remove_job job_id
      job_id = job_id.id unless job_id.is_a? Integer
      jobs.reject! { |job| job.id == job_id }
    end

    def fail_job! job, error = nil
      job.fail!
      job.errors << error unless error.nil? || job.errors.include?(error)
      if job.try_count > max_job_fails
        remove_job job
        nil
      else
        job
      end
    end

    def due_jobs
      jobs.select { |job| job.is_due? }
    end

    private

      def max_job_fails
        100
      end

      def job_exists? job
        jobs.select do |j|
          j.name == job.name &&
            j.start_time == job.start_time &&
            j.end_time == job.end_time &&
            j.day == job.day
        end.any?
      end
  end
end
