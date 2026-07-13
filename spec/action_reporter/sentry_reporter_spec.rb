require "spec_helper"
require "sentry-ruby"
require "action_reporter/sentry_reporter"

RSpec.describe ActionReporter::SentryReporter do
  subject(:instance) { described_class.new }

  before do
    Sentry.init do |config|
      config.dsn = "https://example.com"
    end
  end

  describe "#notify" do
    let(:error) { StandardError.new("Error") }
    let(:context) { {foo: "bar"} }

    it "sends notification", :aggregate_failures do
      allow(Sentry).to receive(:with_scope).and_call_original
      allow(Sentry).to receive(:capture_exception).and_call_original
      instance.notify(error, context: context)
      expect(Sentry).to have_received(:with_scope)
      expect(Sentry).to have_received(:capture_exception).with(error)
    end

    context "when error is a string" do
      let(:error) { "Error" }

      it "sends notification", :aggregate_failures do
        allow(Sentry).to receive(:with_scope).and_call_original
        allow(Sentry).to receive(:capture_message).and_call_original
        instance.notify(error, context: context)
        expect(Sentry).to have_received(:with_scope)
        expect(Sentry).to have_received(:capture_message).with(error)
      end
    end
  end

  describe "#context" do
    let(:context_data) { {foo: "bar"} }

    it "merges context into the Sentry scope" do
      instance.context(context_data)
      expect(Sentry.get_current_scope.contexts["context"]).to eq(foo: "bar")
    end

    it "accumulates keys across chained calls" do
      instance.context(foo: "bar")
      instance.context(baz: "qux")
      expect(Sentry.get_current_scope.contexts["context"]).to eq(foo: "bar", baz: "qux")
    end

    it "transforms context" do
      gid = double("GlobalId", to_s: "gid://app/User/1")
      user = double("User", to_global_id: gid)
      instance.context(foo: "bar", user: user)
      expect(Sentry.get_current_scope.contexts["context"]).to eq(
        foo: "bar",
        user: "gid://app/User/1"
      )
    end

    it "removes keys when nil is passed" do
      instance.context(foo: "bar", baz: "qux")
      instance.context(foo: nil)
      expect(Sentry.get_current_scope.contexts["context"]).to eq(baz: "qux")
    end
  end

  describe "#reset_context" do
    it "clears reporter context from the Sentry scope" do
      instance.context(foo: "bar")
      instance.reset_context
      expect(Sentry.get_current_scope.contexts).not_to have_key("context")
    end
  end

  describe "#current_user=" do
    after do
      ActionReporter.user_id_resolver = nil
    end

    let(:sample_id) { double("GlobalId", to_s: "user-global-id") }
    let(:user) { double("User", to_global_id: sample_id) }

    it "sets user id" do
      allow(Sentry).to receive(:set_user).and_call_original
      instance.current_user = user
      expect(Sentry).to have_received(:set_user).with(id: sample_id.to_s)
    end

    context "when user is nil" do
      let(:user) { nil }

      it "sets empty user id" do
        allow(Sentry).to receive(:set_user).and_call_original
        instance.current_user = user
        expect(Sentry).to have_received(:set_user).with(id: "")
      end
    end

    context "when ActionReporter.user_id_resolver is set" do
      it "uses resolved id" do
        ActionReporter.user_id_resolver = ->(_) { "custom-user-id" }
        allow(Sentry).to receive(:set_user).and_call_original
        instance.current_user = user
        expect(Sentry).to have_received(:set_user).with(id: "custom-user-id")
      end
    end
  end

  describe "#transaction_id=" do
    let(:transaction_id) { "txn-123" }

    it "sets transaction_id tag" do
      allow(Sentry).to receive(:set_tags).and_call_original
      instance.transaction_id = transaction_id
      expect(Sentry).to have_received(:set_tags).with(transaction_id: transaction_id)
    end
  end

  describe "#transaction_name=" do
    let(:transaction_name) { "GET /api/users" }

    it "sets transaction name on scope", :aggregate_failures do
      scope = Sentry.get_current_scope
      allow(Sentry).to receive(:configure_scope).and_yield(scope)
      allow(scope).to receive(:set_transaction_name).and_call_original
      instance.transaction_name = transaction_name
      expect(Sentry).to have_received(:configure_scope)
      expect(scope).to have_received(:set_transaction_name).with(transaction_name)
    end
  end
end
