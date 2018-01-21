require 'gym_webcrawler/scheduler'

RSpec.describe GymWebcrawler::Scheduler do
  let(:logger) { GymWebcrawler::SchedulerLogger.new 'spec/support/files/test-log.txt', 'weekly' }
  let(:scheduler) { described_class.new logger }

  subject { scheduler }

  describe '#align_scheduler' do
    subject { scheduler.align_scheduler }

    before do
      allow(scheduler).to receive(:get_numeric_day) { today }
    end

    shared_examples 'queues correct number of jobs' do
      def total_jobs_count
        get_jobs_count_for_day(today) + get_jobs_count_for_next_2_days
      end

      def get_jobs_count_for_day day
        GymWebcrawler::JobDefinitions.new(day).jobs_for_day.count
      end

      def get_jobs_count_for_next_2_days
        if today == 5
          get_jobs_count_for_day(6) + get_jobs_count_for_day(0)
        elsif today == 6
          get_jobs_count_for_day(0) + get_jobs_count_for_day(1)
        else
          get_jobs_count_for_day(today + 1) + get_jobs_count_for_day(today + 2)
        end
      end

      it { expect { subject }.to change { scheduler.job_stack.jobs.count }.by total_jobs_count }
    end

    0..6.times do |count|
      it_behaves_like "queues correct number of jobs" do
        let(:today) { count }
      end
    end
  end
end
