require "spec_helper"
require "scout_apm"
require "action_reporter/scout_apm_reporter"

RSpec.describe ActionReporter::ScoutApmReporter do
  subject(:instance) { described_class.new }

  describe "#notify" do
    let(:error) { StandardError.new("error") }
    let(:context_data) { {foo: "bar"} }

    before do
      ScoutApm::Context.current.instance_variable_set(:@extra, {})
    end

    it "sets context" do
      instance.notify(error, context: context_data)
      extra = ScoutApm::Context.current.instance_variable_get(:@extra)
      expect(extra).to eq(context_data)
    end

    it "captures error" do
      allow(ScoutApm::Error).to receive(:capture).and_call_original
      instance.notify(error, context: context_data)
      expect(ScoutApm::Error).to have_received(:capture).with(error)
    end
  end

  describe "#context" do
    let(:context_data) { {foo: "bar"} }

    before do
      ScoutApm::Context.current.instance_variable_set(:@extra, {})
    end

    it "sets context" do
      instance.context(context_data)
      extra = ScoutApm::Context.current.instance_variable_get(:@extra)
      expect(extra).to eq(context_data)
    end

    it "merges with existing context" do
      ScoutApm::Context.current.instance_variable_set(:@extra, {baz: "qux"})
      instance.context(context_data)
      extra = ScoutApm::Context.current.instance_variable_get(:@extra)
      expect(extra).to eq(baz: "qux", foo: "bar")
    end

    it "transforms context" do
      gid = double("GlobalId", to_s: "gid://app/User/1")
      user = double("User", to_global_id: gid)
      nested = {foo: "bar", user: user}
      instance.context(nested)
      extra = ScoutApm::Context.current.instance_variable_get(:@extra)
      expect(extra).to eq(foo: "bar", user: "gid://app/User/1")
    end

    it "removes keys when nil is passed" do
      ScoutApm::Context.current.instance_variable_set(:@extra, {foo: "bar", baz: "qux"})
      instance.context(foo: nil)
      extra = ScoutApm::Context.current.instance_variable_get(:@extra)
      expect(extra).to eq(baz: "qux")
    end

    it "clears transaction context after block" do
      ActionReporter.enabled_reporters = [instance]
      ActionReporter.transaction(foo: "bar") {}
      extra = ScoutApm::Context.current.instance_variable_get(:@extra)
      expect(extra).to eq({})
    ensure
      ActionReporter.enabled_reporters = []
    end
  end

  describe "#reset_context" do
    it "clears ScoutApm context" do
      allow(ScoutApm::Context).to receive(:clear!)
      instance.reset_context
      expect(ScoutApm::Context).to have_received(:clear!)
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
