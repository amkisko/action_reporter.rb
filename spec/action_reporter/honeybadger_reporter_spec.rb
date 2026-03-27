require "spec_helper"
require "honeybadger"
require "action_reporter/honeybadger_reporter"

RSpec.describe ActionReporter::HoneybadgerReporter do
  subject(:instance) { described_class.new }

  before do
    Honeybadger.configure do |config|
    end
  end

  describe "#notify" do
    let(:error) { StandardError.new("error") }
    let(:context_data) { {foo: "bar"} }

    it "captures error" do
      allow(Honeybadger).to receive(:notify).and_call_original
      instance.notify(error, context: context_data)
      expect(Honeybadger).to have_received(:notify).with(error, {context: context_data})
    end
  end

  describe "#context" do
    let(:context_data) { {foo: "bar"} }

    it "sets context" do
      allow(Honeybadger).to receive(:context).and_call_original
      instance.context(context_data)
      expect(Honeybadger).to have_received(:context).with(context_data)
    end

    it "transforms context" do
      gid = double("GlobalId", to_s: "gid://app/User/1")
      user = double("User", to_global_id: gid)
      nested = {foo: "bar", user: user}
      allow(Honeybadger).to receive(:context).and_call_original
      instance.context(nested)
      expect(Honeybadger).to have_received(:context).with(foo: "bar", user: "gid://app/User/1")
    end
  end

  describe "#reset_context" do
    let(:new_context) { {foo: "bar"} }

    before do
      Honeybadger.context.clear!
      Honeybadger.context(new_context)
    end

    it "resets context", :aggregate_failures do
      expect(Honeybadger.get_context).to eq(new_context)
      allow(Honeybadger.context).to receive(:clear!).and_call_original
      instance.reset_context
      expect(Honeybadger.context).to have_received(:clear!)
      expect(Honeybadger.get_context).to be_nil
    end
  end

  describe "#current_user=" do
    after do
      ActionReporter.user_id_resolver = nil
    end

    let(:sample_id) { double("GlobalId", to_s: "user-global-id") }
    let(:user) { double("User", to_global_id: sample_id) }

    it "sets user_id from resolve_user_id" do
      allow(Honeybadger).to receive(:context).and_call_original
      instance.current_user = user
      expect(Honeybadger).to have_received(:context).with(user_id: sample_id.to_s)
    end

    context "when user is nil" do
      let(:user) { nil }

      it "sets empty user_id" do
        allow(Honeybadger).to receive(:context).and_call_original
        instance.current_user = user
        expect(Honeybadger).to have_received(:context).with(user_id: "")
      end
    end

    context "when ActionReporter.user_id_resolver is set" do
      it "uses resolved id" do
        ActionReporter.user_id_resolver = ->(_) { "custom-user-id" }
        allow(Honeybadger).to receive(:context).and_call_original
        instance.current_user = user
        expect(Honeybadger).to have_received(:context).with(user_id: "custom-user-id")
      end
    end
  end

  describe "#check_in" do
    context "when identifier is a class" do
      let(:reporter_check_in) { "reporter_check_in_test" }
      let(:identifier) { double("User", reporter_check_in: reporter_check_in) }

      before do
        stub_request(:get, "https://api.honeybadger.io/v1/check_in/#{reporter_check_in}").to_return(status: 200, body: "", headers: {})
      end

      it "returns identifier" do
        allow(Honeybadger).to receive(:check_in).and_call_original
        instance.check_in(identifier)
        expect(Honeybadger).to have_received(:check_in).with(reporter_check_in)
      end
    end
  end
end
