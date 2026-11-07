require "spec_helper"
require "scout_apm"
require "action_reporter/scout_apm_reporter"

RSpec.describe ActionReporter::ScoutApmReporter do
  subject(:instance) { described_class.new }

  def scout_context
    ScoutApm::Context.current
  end

  def scout_extra
    scout_context.instance_variable_get(:@extra)
  end

  def scout_user
    scout_context.instance_variable_get(:@user)
  end

  before do
    scout_context.instance_variable_set(:@extra, {})
    scout_context.instance_variable_set(:@user, {})
  end

  describe "#notify" do
    let(:error) { StandardError.new("error") }
    let(:context_data) { {foo: "bar"} }

    it "captures error with notify context without retaining it", :aggregate_failures do
      scout_context.instance_variable_set(:@extra, {kept: "yes"})
      allow(ScoutApm::Error).to receive(:capture) do
        expect(scout_extra).to eq(kept: "yes", foo: "bar")
      end

      instance.notify(error, context: context_data)

      expect(ScoutApm::Error).to have_received(:capture).with(error)
      expect(scout_extra).to eq(kept: "yes")
    end
  end

  describe "#context" do
    let(:context_data) { {foo: "bar"} }

    it "sets context" do
      instance.context(context_data)
      expect(scout_extra).to eq(context_data)
    end

    it "merges with existing context" do
      scout_context.instance_variable_set(:@extra, {baz: "qux"})
      instance.context(context_data)
      expect(scout_extra).to eq(baz: "qux", foo: "bar")
    end

    it "transforms context" do
      gid = double("GlobalId", to_s: "gid://app/User/1")
      user = double("User", to_global_id: gid)
      nested = {foo: "bar", user: user}
      instance.context(nested)
      expect(scout_extra).to eq(foo: "bar", user: "gid://app/User/1")
    end

    it "removes keys when nil is passed" do
      scout_context.instance_variable_set(:@extra, {foo: "bar", baz: "qux"})
      instance.context(foo: nil)
      expect(scout_extra).to eq(baz: "qux")
    end

    it "clears transaction context after block" do
      ActionReporter.enabled_reporters = [instance]
      ActionReporter.transaction(foo: "bar") {}
      expect(scout_extra).to eq({})
    ensure
      ActionReporter.enabled_reporters = []
    end
  end

  describe "#reset_context" do
    it "clears user and extra context while leaving the request object", :aggregate_failures do
      instance.current_user = "previous-user"
      instance.current_remote_addr = "127.0.0.1"
      instance.context(foo: "bar")

      instance.reset_context

      expect(scout_user).to eq({})
      expect(scout_extra).to eq({})
    end
  end

  describe "#ignore_transaction!" do
    it "ignores the current Scout transaction" do
      allow(ScoutApm::Transaction).to receive(:ignore!)
      instance.ignore_transaction!
      expect(ScoutApm::Transaction).to have_received(:ignore!)
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
