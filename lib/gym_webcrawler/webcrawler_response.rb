module GymWebcrawler
  class WebcrawlerResponse
    attr_accessor :action
    attr_reader :job, :status, :message

    def initialize job:, status:, message:;
      @job = job
      @status = status
      @message = message
      @action = action_for_response_message
    end

    private

      def action_for_response_message
        case message
        when 'Reservation failed. You are already registered for this activity! We are sorry, this activity is fully booked already.'
          'delete'
        when 'Reservation failed. You are already registered for this activity! This activity is no longer available'
          'delete'
        when 'Reservation failed. This activity is no longer available'
          'delete'
        when 'Reservation failed. You are already registered for this activity!'
          'delete'
        when 'Reservation failed. We are sorry, this activity is fully booked already.'
          'delete'
        when 'Reservation failed. You have cancelled this reservation. You cannot register again.'
          'delete'
        when 'Your reservation is confirmed. Please check your email.'
          'success'
        when 'Reservation failed. You are not logged in.'
          'fail'
        else
          'fail'
        end
      end
  end
end
