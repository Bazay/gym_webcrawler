require 'gym_webcrawler/job_manager'
require 'gym_webcrawler/job_stack'
require 'gym_webcrawler/webcrawler_response'

RSpec.describe GymWebcrawler::JobManager do
  let(:logger) { GymWebcrawler::SchedulerLogger.new 'spec/support/files/test-log.txt', 'weekly' }
  let(:job_stack) { GymWebcrawler::JobStack.new }
  let(:job_manager) { described_class.new logger, job_stack }

  subject { job_manager }

  its(:webcrawler) { is_expected.to be_a GymWebcrawler::Webcrawler }

  describe '#handle_responses' do
    let!(:job) { job_stack.add_job job_stack.build_job job_options }
    let :job_options do
      { name: 'Boxing with Harry', start_time: '07:30', end_time: '08:30', day: 1, job_at: Time.now }
    end
    let(:responses) { [ GymWebcrawler::WebcrawlerResponse.new( job: job, status: status, message: message) ] }

    subject { job_manager.handle_responses responses }
    
    context 'when response is a \'delete\' action' do
      let(:status) { 'error' }
      let(:message) { 'Reservation failed. This activity is no longer available' }

      it { expect { subject }.to change { job_stack.jobs.count }.by -1 }
    end

    context 'when response is a \'fail\' action' do
      let(:status) { 'error' }
      let(:message) { 'Reservation failed. You are not logged in.' }

      it { expect { subject }.to change { job.try_count }.by 1 }
    end

    context 'when response is a \'success\' action' do
      let(:status) { 'success' }
      let(:message) { 'Your reservation is confirmed. Please check your email.' }

      it { expect { subject }.to change { job_stack.jobs.count }.by -1 }
    end
  end
end
