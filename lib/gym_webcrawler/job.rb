require_relative 'scheduler'

module GymWebcrawler
  class Job
    attr_accessor :id, :name, :start_time, :end_time, :day, :job_at, :try_count, :errors

    def initialize id: nil, name:, start_time:, end_time:, day:, job_at:;
      @id = id
      @name = name
      @start_time = start_time
      @end_time = end_time
      @day = day
      @job_at = job_at
      @try_count = 0
      @errors = []
    end

    def fail!
      self.try_count += 1
    end

    def is_due?
      job_at < Time.now + advance_period
    end

    private

      def day_numeric_conversion
        DateTime.parse(day).wday
      end

      def advance_period
        Scheduler::ADVANCE_PERIOD
      end
  end
end
