require 'spec_helper'
require 'sentry-ruby'

RSpec.describe ActionReporter::SentryReporter do
  subject { described_class.new }

  before do
    Sentry.init do |config|
      config.dsn = 'https://example.com'
    end
  end

  describe '#notify' do
    context "when error is an exception" do
      let(:error) { StandardError.new('Error') }

      it 'sends notification' do
        # expect(Sentry).to receive(:get_current_scope).and_call_original
        expect(Sentry).to receive(:capture_exception).with(error).and_call_original
        subject.notify(error, context: { foo: 'bar' })
      end
    end

    context "when error is a string" do
      let(:error) { 'Error' }

      it 'sends notification' do
        # expect(Sentry).to receive(:get_current_scope).and_call_original
        expect(Sentry).to receive(:capture_message).with(error).and_call_original
        subject.notify(error, context: { foo: 'bar' })
      end
    end
  end

  describe '#context' do
    it 'sets context' do
      expect(Sentry).to receive(:get_current_scope).and_call_original
      subject.context({ foo: 'bar' })
    end
  end
end
