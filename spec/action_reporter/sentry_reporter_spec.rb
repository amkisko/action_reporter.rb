require 'spec_helper'
require 'sentry-ruby'

RSpec.describe ActionReporter::SentryReporter do
  subject(:instance) { described_class.new }

  before do
    Sentry.init do |config|
      config.dsn = 'https://example.com'
    end
  end

  describe '#notify' do
    subject(:notify) { instance.notify(error, context: context) }

    let(:error) { StandardError.new('Error') }
    let(:context) { { foo: 'bar' } }

    it 'sends notification' do
      expect(Sentry).to receive(:with_scope).and_call_original
      expect(Sentry).to receive(:capture_exception).with(error).and_call_original
      subject
    end

    context "when error is a string" do
      let(:error) { 'Error' }

      it 'sends notification' do
        expect(Sentry).to receive(:with_scope).and_call_original
        expect(Sentry).to receive(:capture_message).with(error).and_call_original
        subject
      end
    end
  end

  describe '#context' do
    subject(:context) { instance.context(context_data) }

    let(:context_data) { { foo: 'bar' } }

    it 'sets context' do
      expect(Sentry.get_current_scope).to receive(:set_context).with("context", context_data).and_call_original
      subject
    end

    it 'transforms context' do
      expect(instance).to receive(:transform_context).with(context_data).and_call_original
      subject
    end
  end

  describe '#reset_context' do
    subject(:reset_context) { instance.reset_context }

    it 'resets context' do
      expect(Sentry.get_current_scope).to receive(:set_context).with("context", {}).and_call_original
      subject
    end
  end

  describe '#current_user=' do
    subject(:current_user=) { instance.current_user = user }

    let(:sample_id) { double("GlobalId", to_s: "user-global-id") }
    let(:user) { double("User", to_global_id: sample_id) }

    it 'sets user_global_id' do
      expect(Sentry).to receive(:set_user).with(user_global_id: sample_id.to_s).and_call_original
      subject
    end
  end
end
