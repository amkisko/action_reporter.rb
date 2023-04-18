require 'spec_helper'

RSpec.describe ActionReporter do
  it 'has a version number' do
    expect(ActionReporter::VERSION).not_to be nil
  end

  describe '.enabled_reporters' do
    subject(:enabled_reporters) { described_class.enabled_reporters }

    it 'returns enabled reporters' do
      expect(subject).to eq([])
    end

    context 'when Rails is defined' do
      let(:rails_reporter) { ActionReporter::RailsReporter.new }
      before do
        described_class.enabled_reporters = [
          rails_reporter
        ]
      end
      it 'returns enabled reporters' do
        expect(subject).to eq([rails_reporter])
      end
    end
  end

  describe '.notify' do

  end

  describe '.context' do

  end

  describe '.reset_context' do

  end

  describe '.audited_user' do
    context 'when AuditedReporter is enabled' do
      let(:audited_reporter) { ActionReporter::AuditedReporter.new }
      let(:audited_stub) { double('Audited') }
      before do
        described_class.enabled_reporters = [
          audited_reporter
        ]
        allow(audited_stub).to receive(:store).and_return({ audited_user: 'user' })
        stub_const('Audited', audited_stub)
      end

      it 'returns audited_user' do
        expect(described_class.audited_user).to eq('user')
      end
    end
  end
end
