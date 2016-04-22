require_relative './../../lib/extensions/capybara'
require 'capybara-screenshot'
require_relative 'webcrawler_response'

module GymWebcrawler
  class Webcrawler < Struct.new(:logger)
    attr_accessor :session, :responses

    def initialize *args
      super
      @session = Capybara::Session.new(:poltergeist)
      @responses = []
    end

    def perform jobs
      begin
        # Start crawling!
        enrol_in_classes current_user, jobs
      rescue => error
        raise error
      # ensure
      #   # Prevent memory leakage
      #   session.driver.quit
      end
    end

    def enrol_in_classes user, jobs
      go_to_website
      sign_in user
      jobs.each do |job|
        self.responses << try_enrol(job)
      end
      responses
    end

    def try_enrol job
      wait_for_javascript

      # Click on lesson
      find_lesson(job).click
      wait_for_javascript

      # Click confirm in modal popup
      confirm_lesson

      wait_for_slow_javascript

      # Get confirmation message
      modal_status = session.find('.modal-dialog').find('.bootstrap-dialog-title').text.downcase
      modal_message = session.find('.modal-dialog').find('.bootstrap-dialog-message').text

      # Dismiss modal
      session.find('.modal-dialog').find('.btn-default').click

      wait_for_javascript

      WebcrawlerResponse.new job: job, status: modal_status, message: modal_message
    end

    def go_to_website
      session.visit 'http://reservations.fightcitygym.com/'
    end

    def sign_in user = current_user
      session.click_link 'Login'
      session.fill_in 'email', with: user[:email]
      session.fill_in 'password', with: user[:password]
      session.click_button 'Login'
    end

    def find_lesson job
      session.find('.fc-content-skeleton')
        .all('td')[job.day]
        .find("div[data-full='#{formatted_time(job.start_time)} - #{formatted_time(job.end_time)}']")
    end

    def confirm_lesson
      modal = session.find('.modal-dialog')
      modal.find('.btn-warning').click
    end

    private

      def current_user
        { email: 'baronbloomer@gmail.com', password: '' }
      end

      def formatted_time time
        hour = time.split(':').first.to_i
        minute = time.split(':').last
        meridiem = hour >= 12 ? 'PM' : 'AM'
        hour = hour > 12 ? hour - 12 : hour
        "#{hour}:#{minute} #{meridiem}"
      end

      def wait_for_javascript
        sleep 0.5
      end

      def wait_for_slow_javascript
        sleep 10
      end
  end
end
