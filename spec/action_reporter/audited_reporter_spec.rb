require "spec_helper"
require "rails"
require "audited"

RSpec.describe ActionReporter::AuditedReporter do
  subject(:instance) { described_class.new }

  describe "#notify" do
    it "does nothing" do
      expect { subject.notify("error") }.not_to raise_error
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
      expect(Audited).to receive(:context=).with(context_data)
      subject.context(context_data)
    end

    context "when Audited doesn't respond to context=" do
      before do
        allow(Audited).to receive(:respond_to?).with(:context=).and_return(false)
      end

      it "does not set context" do
        expect(Audited).not_to receive(:context=)
        subject.context(context_data)
      end
    end
  end

  describe "#current_request_uuid" do
    it "returns current_request_uuid from store" do
      uuid = "123-456-789"
      Audited.store[:current_request_uuid] = uuid
      expect(subject.current_request_uuid).to eq(uuid)
    end
  end

  describe "#current_request_uuid=" do
    it "sets current_request_uuid in store" do
      uuid = "123-456-789"
      subject.current_request_uuid = uuid
      expect(Audited.store[:current_request_uuid]).to eq(uuid)
    end
  end

  describe "#current_remote_addr" do
    it "returns current_remote_address from store" do
      addr = "192.168.1.1"
      Audited.store[:current_remote_address] = addr
      expect(subject.current_remote_addr).to eq(addr)
    end
  end

  describe "#current_remote_addr=" do
    it "sets current_remote_address in store" do
      addr = "192.168.1.1"
      subject.current_remote_addr = addr
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
      expect(subject.current_user).to eq(user)
    end
  end

  describe "#current_user=" do
    before do
      Audited.store[:audited_user] = nil
    end

    it "sets audited_user" do
      user = double("User", to_global_id: "gid://user/1")
      expect(Audited.store[:audited_user]).to eq(nil)
      instance.current_user = user
      expect(Audited.store[:audited_user]).to eq(user)
    end
  end

  describe "#reset_context" do
    subject(:reset_context) { instance.reset_context }

    it "resets context" do
      expect(Audited.store).to receive(:delete).with(:current_remote_address)
      expect(Audited.store).to receive(:delete).with(:current_request_uuid)
      expect(Audited.store).to receive(:delete).with(:audited_user)
      subject
    end
  end
end
