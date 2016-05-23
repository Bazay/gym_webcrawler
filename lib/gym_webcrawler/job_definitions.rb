require 'chronic'

module GymWebcrawler
  class JobDefinitions
    attr_reader :day

    def initialize day
      @day = day
    end

    def jobs_for_day
      case day
      when 'monday', 1
        jobs_for_monday
      when 'wednesday', 3
        jobs_for_wednesday
      when 'thursday', 4
        jobs_for_thursday
      when 'saturday', 6
        jobs_for_saturday
      else
        []
      end
    end

    private

      def job_info_parser name, start_time, end_time
        { name: name, start_time: start_time, end_time: end_time, day: day, job_at: get_job_at(start_time) }
      end

      def get_job_at start_time
        Chronic.parse("this #{get_string_day(day)} at #{start_time}")
      end

      def jobs_for_monday
        [
          job_info_parser('Boxing with Harry', '07:30', '8:30'),
          job_info_parser('Boxing with Harry', '18:00', '19:00')
        ]
      end

      def jobs_for_wednesday
        [
          job_info_parser('Boxing with Harry', '07:30', '8:30')
        ]
      end

      def jobs_for_thursday
        [
          job_info_parser('Boxing Tech Sparring with Harry', '18:00', '18:45')
        ]
      end

      def jobs_for_saturday
        [
          job_info_parser('Boxing with Ryan', '13:00', '14:00'),
          job_info_parser('Boxing Sparring with Ryan', '14:00', '15:00')
        ]
      end

      def get_string_day day_number
        Date::DAYNAMES[day_number].downcase
      end
  end
end
