require "spec_helper"
require "rails"
require "audited"
require "action_reporter/audited_reporter"

RSpec.describe ActionReporter::AuditedReporter do
  subject(:instance) { described_class.new }

  describe "#notify" do
    it "does nothing" do
      expect { instance.notify("error") }.not_to raise_error
    end
  end

  describe "#context" do
    let(:context_data) { {foo: "bar"} }

    before do
      allow(Audited).to receive(:respond_to?).with(:context=).and_return(true)
      allow(Audited).to receive(:context).and_return({})
      allow(Audited).to receive(:context=)
    end

    it "merges context" do
      instance.context(context_data)
      expect(Audited).to have_received(:context=).with(context_data)
    end

    context "when Audited doesn't respond to context=" do
      before do
        allow(Audited).to receive(:respond_to?).with(:context=).and_return(false)
      end

      it "does not set context" do
        allow(Audited).to receive(:context=)
        instance.context(context_data)
        expect(Audited).not_to have_received(:context=)
      end
    end
  end

  describe "#current_request_uuid" do
    it "returns current_request_uuid from store" do
      uuid = "123-456-789"
      Audited.store[:current_request_uuid] = uuid
      expect(instance.current_request_uuid).to eq(uuid)
    end
  end

  describe "#current_request_uuid=" do
    it "sets current_request_uuid in store" do
      uuid = "123-456-789"
      instance.current_request_uuid = uuid
      expect(Audited.store[:current_request_uuid]).to eq(uuid)
    end
  end

  describe "#current_remote_addr" do
    it "returns current_remote_address from store" do
      addr = "192.168.1.1"
      Audited.store[:current_remote_address] = addr
      expect(instance.current_remote_addr).to eq(addr)
    end
  end

  describe "#current_remote_addr=" do
    it "sets current_remote_address in store" do
      addr = "192.168.1.1"
      instance.current_remote_addr = addr
      expect(Audited.store[:current_remote_address]).to eq(addr)
    end
  end

  describe "#current_user" do
    before do
      Audited.store[:audited_user] = nil
    end

    it "returns current_user from store" do
      user = double("User", to_global_id: "gid://user/1")
      Audited.store[:audited_user] = user
      expect(instance.current_user).to eq(user)
    end
  end

  describe "#current_user=" do
    before do
      Audited.store[:audited_user] = nil
    end

    it "sets audited_user", :aggregate_failures do
      user = double("User", to_global_id: "gid://user/1")
      expect(Audited.store[:audited_user]).to be_nil
      instance.current_user = user
      expect(Audited.store[:audited_user]).to eq(user)
    end
  end

  describe "#reset_context" do
    it "resets context", :aggregate_failures do
      store = Audited.store
      allow(store).to receive(:delete).and_call_original
      instance.reset_context
      expect(store).to have_received(:delete).with(:current_remote_address)
      expect(store).to have_received(:delete).with(:current_request_uuid)
      expect(store).to have_received(:delete).with(:audited_user)
    end
  end
end
