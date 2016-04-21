require 'gym_webcrawler/scheduler'

RSpec.describe GymWebcrawler::Scheduler do
  let(:logger) { GymWebcrawler::SchedulerLogger.new 'spec/support/files/test-log.txt', 'weekly' }
  let(:scheduler) { described_class.new logger }

  subject { scheduler }

  describe '#align_scheduler' do
    before do
      allow(scheduler).to receive(:get_numeric_day) { day }
    end

    subject { scheduler.align_scheduler }

    context 'when sunday' do
      let(:day) { 0 }

      it { expect{ subject }.to change { scheduler.job_stack.jobs.count }.by 2 }
    end

    context 'when monday' do
      let(:day) { 1 }

      it { expect{ subject }.to change { scheduler.job_stack.jobs.count }.by 3 }
    end

    context 'when tuesday' do
      let(:day) { 2 }

      it { expect{ subject }.to change { scheduler.job_stack.jobs.count }.by 2 }
    end

    context 'when wednesday' do
      let(:day) { 3 }

      it { expect{ subject }.to change { scheduler.job_stack.jobs.count }.by 2 }
    end

    context 'when thursday' do
      let(:day) { 4 }

      it { expect{ subject }.to change { scheduler.job_stack.jobs.count }.by 3 }
    end

    context 'when friday' do
      let(:day) { 5 }

      it { expect{ subject }.to change { scheduler.job_stack.jobs.count }.by 2 }
    end

    context 'when saturday' do
      let(:day) { 6 }

      it { expect{ subject }.to change { scheduler.job_stack.jobs.count }.by 2 }
    end
  end
end
