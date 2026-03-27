require "spec_helper"
require "scout_apm"
require "action_reporter/scout_apm_reporter"

RSpec.describe ActionReporter::ScoutApmReporter do
  subject(:instance) { described_class.new }

  describe "#notify" do
    subject(:notify) { instance.notify(error, context: context_data) }

    let(:error) { StandardError.new("error") }
    let(:context_data) { {foo: "bar"} }

    it "sets context" do
      expect(ScoutApm::Context).to receive(:add).with(context_data).and_call_original
      subject
    end

    it "captures error" do
      expect(ScoutApm::Error).to receive(:capture).with(error).and_call_original
      subject
    end
  end

  describe "#context" do
    subject(:context) { instance.context(context_data) }

    let(:context_data) { {foo: "bar"} }

    it "sets context" do
      expect(ScoutApm::Context).to receive(:add).with(context_data).and_call_original
      subject
    end

    it "transforms context" do
      expect(instance).to receive(:transform_context).with(context_data).and_call_original
      subject
    end
  end

  describe "#reset_context" do
    it "does nothing" do
      expect { subject.reset_context }.not_to raise_error
    end
  end

  describe "#ignore_transaction!" do
    it "calls ignore_transaction! on ScoutApm::Context" do
      expect(ScoutApm::Context).to receive(:ignore_transaction!)
      subject.ignore_transaction!
    end
  end

  describe "#current_user=" do
    subject(:current_user=) { instance.current_user = user }

    after do
      ActionReporter.user_id_resolver = nil
    end

    let(:sample_id) { double("GlobalId", to_s: "user-global-id") }
    let(:user) { double("User", to_global_id: sample_id) }

    it "sets current_user" do
      expect(ScoutApm::Context).to receive(:add_user).with(id: sample_id.to_s).and_call_original
      subject
    end

    context "when user is nil" do
      let(:user) { nil }

      it "adds empty id" do
        expect(ScoutApm::Context).to receive(:add_user).with(id: "").and_call_original
        subject
      end
    end

    context "when ActionReporter.user_id_resolver is set" do
      it "uses resolved id" do
        ActionReporter.user_id_resolver = ->(_) { "custom-user-id" }
        expect(ScoutApm::Context).to receive(:add_user).with(id: "custom-user-id").and_call_original
        instance.current_user = user
      end
    end
  end
end
