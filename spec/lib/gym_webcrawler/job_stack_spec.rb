require 'gym_webcrawler/job'
require 'gym_webcrawler/job_stack'

RSpec.describe GymWebcrawler::JobStack do
  let(:job_stack) { described_class.new }
  let(:job) { job_stack.build_job job_options }
  let(:job_options) { { name: name, start_time: start_time, end_time: end_time, day: day, job_at: job_at } }
  let(:name) { 'Boxing with Harry' }
  let(:start_time) { '07:30' }
  let(:end_time) { '08:30' }
  let(:day) { 1 }
  let(:job_at) { Time.now }

  subject { job_stack }

  describe '#build_job' do

    subject { job }

    its(:class) { is_expected.to eq GymWebcrawler::Job }
    its(:id) { is_expected.to eq nil }
    its(:name) { is_expected.to eq name }
    its(:start_time) { is_expected.to eq start_time }
    its(:end_time) { is_expected.to eq end_time }
    its(:day) { is_expected.to eq day }
    its(:job_at) { is_expected.to eq job_at }
  end

  describe '#add_job' do
    subject { job_stack.add_job job }

    its(:id) { is_expected.to eq job_stack.job_count - 1 }
    it { expect{ subject }.to change { job_stack.jobs.count }.by 1 }

    context 'when job already exists' do
      before { job_stack.add_job job }

      subject { job_stack.add_job job }

      it { is_expected.to eq nil }
      it { expect { subject }.to change { job_stack.jobs.count }.by 0 }
    end
  end

  describe '#remove_job' do
    let!(:job) { job_stack.add_job job_stack.build_job job_options }

    subject { job_stack.remove_job job }

    it { expect { subject }.to change { job_stack.jobs.count }.by -1 }
    it { is_expected.to eq job_stack.jobs }
  end

  describe '#fail_job!' do
    let!(:job) { job_stack.add_job job_stack.build_job job_options }

    subject { job_stack.fail_job! job }

    it { is_expected.to eq job }
    it { expect { subject }.to change { job.try_count }.by 1 }

    context 'when job exceeds try count limit' do
      before { job.try_count = 16 }

      it { is_expected.to eq nil }
      it { expect { subject }.to change { job_stack.jobs.count }.by -1 }
    end
  end

  describe '#due_jobs' do
    let(:undue_period) { 2.5*24*60*60 } # 2.5 days
    let(:undue_job_options) { job_options.merge(job_at: Time.now + undue_period) }
    let!(:undue_job) { job_stack.add_job job_stack.build_job undue_job_options }
    let(:due_jobs) { [] }
    let(:jobs) { (due_jobs << undue_job).sort_by(&:id) }
    
    before do
      # Set a different time for each job to ensure they a different...
      3.times { |count| due_jobs << job_stack.add_job(job_stack.build_job(job_options.merge(start_time: "0#{count+1}:00"))) }
    end

    subject { job_stack.due_jobs }

    it { is_expected.to match_array due_jobs }
    it { expect(job_stack.jobs).to match_array jobs }
  end
end
