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

  describe '.transform_context' do
    subject(:transform_context) { described_class.send(:transform_context, context) }
    let(:context) { { foo: 'bar' } }

    it 'returns context' do
      expect(subject).to eq(context)
    end

    context 'when context contains audited_user' do
      let(:context) { { foo: 'bar', audited_user: 'user' } }

      it 'returns context without audited_user' do
        expect(subject).to eq({ foo: 'bar' })
      end
    end

    context 'when context contains ActiveRecord object' do
      let(:context) { { foo: 'bar', user: user } }
      let(:user) { double('User', to_global_id: 'gid://user/1') }
      it 'returns context with global id' do
        expect(subject).to eq({ foo: 'bar', user: 'gid://user/1' })
      end
    end
  end
end
