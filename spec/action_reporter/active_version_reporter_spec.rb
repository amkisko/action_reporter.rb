require "spec_helper"
require "rails"
require "active_version"
require "action_reporter/active_version_reporter"

RSpec.describe ActionReporter::ActiveVersionReporter do
  subject(:instance) { described_class.new }

  describe "#notify" do
    it "does nothing" do
      expect { instance.notify("error") }.not_to raise_error
    end
  end

  describe "#context" do
    let(:context_data) { {foo: "bar"} }

    before do
      ActiveVersion.context = {}
    end

    it "merges context" do
      instance.context(context_data)
      expect(ActiveVersion.context).to eq(context_data)
    end
  end

  describe "#current_request_uuid" do
    it "returns request_uuid from request store" do
      uuid = "123-456-789"
      ActiveVersion::RequestStore.request_uuid = uuid
      expect(instance.current_request_uuid).to eq(uuid)
    end
  end

  describe "#current_request_uuid=" do
    it "sets request_uuid in request store" do
      uuid = "123-456-789"
      instance.current_request_uuid = uuid
      expect(ActiveVersion::RequestStore.request_uuid).to eq(uuid)
    end
  end

  describe "#current_remote_addr" do
    it "returns remote_address from request store" do
      addr = "192.168.1.1"
      ActiveVersion::RequestStore.remote_address = addr
      expect(instance.current_remote_addr).to eq(addr)
    end
  end

  describe "#current_remote_addr=" do
    it "sets remote_address in request store" do
      addr = "192.168.1.1"
      instance.current_remote_addr = addr
      expect(ActiveVersion::RequestStore.remote_address).to eq(addr)
    end
  end

  describe "#current_user" do
    before do
      ActiveVersion::RequestStore.audited_user = nil
    end

    it "returns current_user from request store" do
      user = double("User", to_global_id: "gid://user/1")
      ActiveVersion::RequestStore.audited_user = user
      expect(instance.current_user).to eq(user)
    end
  end

  describe "#current_user=" do
    before do
      ActiveVersion::RequestStore.audited_user = nil
    end

    it "sets audited_user in request store" do
      user = double("User", to_global_id: "gid://user/1")
      expect(ActiveVersion::RequestStore.audited_user).to eq(nil)
      instance.current_user = user
      expect(ActiveVersion::RequestStore.audited_user).to eq(user)
    end
  end

  describe "#reset_context" do
    it "resets request store and context" do
      ActiveVersion::RequestStore.request_uuid = "123-456-789"
      ActiveVersion::RequestStore.remote_address = "192.168.1.1"
      ActiveVersion::RequestStore.audited_user = double("User")
      ActiveVersion.context = {foo: "bar"}

      instance.reset_context

      expect(ActiveVersion::RequestStore.request_uuid).to be_nil
      expect(ActiveVersion::RequestStore.remote_address).to be_nil
      expect(ActiveVersion::RequestStore.audited_user).to be_nil
      expect(ActiveVersion.context).to eq({})
    end
  end
end
