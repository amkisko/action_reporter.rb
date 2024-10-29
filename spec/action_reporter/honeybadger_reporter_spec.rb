require 'spec_helper'
require 'honeybadger'

RSpec.describe ActionReporter::HoneybadgerReporter do
  subject(:instance) { described_class.new }

  before do
    Honeybadger.configure do |config|

    end
  end

  describe '#notify' do
    subject(:notify) { instance.notify(error, context: context_data) }

    let(:error) { StandardError.new('error') }
    let(:context_data) { { foo: 'bar' } }

    it 'captures error' do
      expect(Honeybadger).to receive(:notify).with(error, { context: context_data }).and_call_original
      subject
    end
  end

  describe '#context' do
    subject(:context) { instance.context(context_data) }

    let(:context_data) { { foo: 'bar' } }

    it 'sets context' do
      expect(Honeybadger).to receive(:context).with(context_data).and_call_original
      subject
    end

    it 'transforms context' do
      expect(instance).to receive(:transform_context).with(context_data).and_call_original
      subject
    end
  end

  describe '#reset_context' do
    subject(:reset_context) { instance.reset_context }
    let(:new_context) { { foo: 'bar' } }

    before do
      Honeybadger.context(new_context)
    end

    it 'resets context' do
      expect(Honeybadger.get_context).to eq(new_context)
      expect(Honeybadger.context).to receive(:clear!).and_call_original
      subject
      expect(Honeybadger.get_context).to eq(nil)
    end
  end

  describe '#current_user=' do
    subject(:current_user=) { instance.current_user = user }

    let(:sample_id) { double("GlobalId", to_s: "user-global-id") }
    let(:user) { double("User", to_global_id: sample_id) }

    it 'sets user_global_id' do
      expect(Honeybadger).to receive(:context).with(user_global_id: sample_id.to_s).and_call_original
      subject
    end
  end

  describe '#check_in' do
    subject(:check_in) { instance.check_in(identifier) }

    context "when identifier is a string" do

    end

    context "when identifier is a class" do
      let(:reporter_check_in) { "reporter_check_in_test" }
      let(:identifier) { double("User", reporter_check_in: reporter_check_in) }

      before do
        stub_request(:get, "https://api.honeybadger.io/v1/check_in/#{reporter_check_in}").to_return(status: 200, body: "", headers: {})
      end

      it 'returns identifier' do
        expect(Honeybadger).to receive(:check_in).with(reporter_check_in).and_call_original
        subject
      end
    end
  end
end
