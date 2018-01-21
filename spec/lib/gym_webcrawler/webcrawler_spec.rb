require 'gym_webcrawler/webcrawler'
require 'gym_webcrawler/job_stack'
require 'gym_webcrawler/job_manager'

RSpec.describe GymWebcrawler::Webcrawler do
  let(:logger) { GymWebcrawler::SchedulerLogger.new 'spec/support/files/test-log.txt', 'weekly' }
  let(:crawler) { described_class.new logger }
  let(:job_stack) { GymWebcrawler::JobStack.new }

  subject { crawler }

  describe '#perform' do
    let(:job) { job_stack.add_job job_stack.build_job job_options }
    let :job_options do
      { name: 'BOXING', start_time: '07:30', end_time: '08:30', day: 1, job_at: Time.now }
    end
    let!(:jobs) { [job] }

    subject { crawler.perform jobs }

    it { is_expected.to be_a Array }

    context 'when multiple jobs' do
      let(:job2_options) do
        { name: 'BOXING', start_time: '18:00', end_time: '19:00', day: 1, job_at: Time.now }
      end
      let(:job2) { job_stack.add_job job_stack.build_job job2_options }
      let!(:jobs) { [job, job2] }

      it { is_expected.to be_a Array }
    end
  end

  describe '#find_lesson' do
    let(:job_manager) { GymWebcrawler::JobManager.new logger, job_stack }
    let(:jobs) { job_stack.jobs }

    shared_examples_for 'finding the correct lesson' do
      before do
        job_manager.create_jobs_for_day(day).each { |job| job_stack.add_job(job_stack.build_job(job)) }
        crawler.go_to_website
        crawler.sign_in
      end

      def get_confirmation_text
        crawler.session.find('.modal-dialog .bootstrap-dialog-message')
      end

      it 'lesson with the correct title' do
        jobs.each do |job|
          crawler.go_to_website
          crawler.find_lesson(job).click
          expect(get_confirmation_text).to have_text(
            "#{formatted_time(job.start_time)} - #{formatted_time(job.end_time)}".downcase
          )
        end
      end
    end

    context 'when monday' do
      let(:day) { 1 }

      it_behaves_like 'finding the correct lesson'
    end

    context 'when tuesday' do
      let(:day) { 2 }

      it_behaves_like 'finding the correct lesson'
    end

    context 'when wednesday' do
      let(:day) { 3 }

      it_behaves_like 'finding the correct lesson'
    end

    context 'when thursday' do
      let(:day) { 4 }

      it_behaves_like 'finding the correct lesson'
    end

    context 'when saturday' do
      let(:day) { 6 }

      it_behaves_like 'finding the correct lesson'
    end
  end

  describe '#sign_out' do
    before do
      crawler.go_to_website
      crawler.sign_in
    end

    subject { crawler.sign_out }

    it { expect { subject }.not_to raise_error }

    context 'when safe is false' do
      subject { crawler.sign_out safe: false }

      it { expect { subject }.not_to raise_error }
    end
  end

  describe '#formatted_time' do
    let(:job_manager) { GymWebcrawler::JobManager.new logger, job_stack }
    let(:jobs) { job_manager.create_jobs_for_day day }

    shared_examples_for 'formatted time for day' do
      let(:expected_start_times) { GymWebcrawler::JobDefinitions.new(day).jobs_for_day.map { |hash| formatted_time(hash[:start_time]) } }
      let(:expected_end_times) { GymWebcrawler::JobDefinitions.new(day).jobs_for_day.map { |hash| formatted_time(hash[:end_time]) } }

      def formatted_time time
        crawler.send :formatted_time, time
      end

      it 'correctly formatted start times' do
        jobs.each_with_index do |job, index|
          expect(formatted_time job[:start_time]).to eq expected_start_times[index]
        end
      end

      it 'correctly formatted end times' do
        jobs.each_with_index do |job, index|
          expect(formatted_time job[:end_time]).to eq expected_end_times[index]
        end
      end
    end

    context 'when monday' do
      let(:day) { 1 }

      it_behaves_like 'formatted time for day'
    end

    context 'when tuesday' do
      let(:day) { 2 }

      it_behaves_like 'formatted time for day'
    end

    context 'when wednesday' do
      let(:day) { 3 }

      it_behaves_like 'formatted time for day'
    end

    context 'when thursday' do
      let(:day) { 4 }

      it_behaves_like 'formatted time for day'
    end

    context 'when saturday' do
      let(:day) { 6 }

      it_behaves_like 'formatted time for day'
    end
  end
end
