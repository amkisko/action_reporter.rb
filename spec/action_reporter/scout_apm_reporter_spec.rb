require "spec_helper"
require "scout_apm"
require "action_reporter/scout_apm_reporter"

RSpec.describe ActionReporter::ScoutApmReporter do
  subject(:instance) { described_class.new }

  describe "#notify" do
    let(:error) { StandardError.new("error") }
    let(:context_data) { {foo: "bar"} }

    it "sets context" do
      allow(ScoutApm::Context).to receive(:add).and_call_original
      instance.notify(error, context: context_data)
      expect(ScoutApm::Context).to have_received(:add).with(context_data)
    end

    it "captures error" do
      allow(ScoutApm::Error).to receive(:capture).and_call_original
      instance.notify(error, context: context_data)
      expect(ScoutApm::Error).to have_received(:capture).with(error)
    end
  end

  describe "#context" do
    let(:context_data) { {foo: "bar"} }

    it "sets context" do
      allow(ScoutApm::Context).to receive(:add).and_call_original
      instance.context(context_data)
      expect(ScoutApm::Context).to have_received(:add).with(context_data)
    end

    it "transforms context" do
      gid = double("GlobalId", to_s: "gid://app/User/1")
      user = double("User", to_global_id: gid)
      nested = {foo: "bar", user: user}
      allow(ScoutApm::Context).to receive(:add).and_call_original
      instance.context(nested)
      expect(ScoutApm::Context).to have_received(:add).with(foo: "bar", user: "gid://app/User/1")
    end
  end

  describe "#reset_context" do
    it "does nothing" do
      expect { instance.reset_context }.not_to raise_error
    end
  end

  describe "#ignore_transaction!" do
    it "calls ignore_transaction! on ScoutApm::Context" do
      allow(ScoutApm::Context).to receive(:ignore_transaction!)
      instance.ignore_transaction!
      expect(ScoutApm::Context).to have_received(:ignore_transaction!)
    end
  end

  describe "#current_user=" do
    after do
      ActionReporter.user_id_resolver = nil
    end

    let(:sample_id) { double("GlobalId", to_s: "user-global-id") }
    let(:user) { double("User", to_global_id: sample_id) }

    it "sets current_user" do
      allow(ScoutApm::Context).to receive(:add_user).and_call_original
      instance.current_user = user
      expect(ScoutApm::Context).to have_received(:add_user).with(id: sample_id.to_s)
    end

    context "when user is nil" do
      let(:user) { nil }

      it "adds empty id" do
        allow(ScoutApm::Context).to receive(:add_user).and_call_original
        instance.current_user = user
        expect(ScoutApm::Context).to have_received(:add_user).with(id: "")
      end
    end

    context "when ActionReporter.user_id_resolver is set" do
      it "uses resolved id" do
        ActionReporter.user_id_resolver = ->(_) { "custom-user-id" }
        allow(ScoutApm::Context).to receive(:add_user).and_call_original
        instance.current_user = user
        expect(ScoutApm::Context).to have_received(:add_user).with(id: "custom-user-id")
      end
    end
  end
end
