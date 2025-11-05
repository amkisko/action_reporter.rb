require "spec_helper"

RSpec.describe ActionReporter::Current do
  describe ".current_user" do
    before do
      described_class.reset
    end

    it "returns nil initially" do
      expect(described_class.current_user).to be_nil
    end

    it "returns set value" do
      user = double("User")
      described_class.current_user = user
      expect(described_class.current_user).to eq(user)
    end
  end

  describe ".current_request_uuid" do
    before do
      described_class.reset
    end

    it "returns nil initially" do
      expect(described_class.current_request_uuid).to be_nil
    end

    it "returns set value" do
      uuid = "123-456-789"
      described_class.current_request_uuid = uuid
      expect(described_class.current_request_uuid).to eq(uuid)
    end
  end

  describe ".current_remote_addr" do
    before do
      described_class.reset
    end

    it "returns nil initially" do
      expect(described_class.current_remote_addr).to be_nil
    end

    it "returns set value" do
      addr = "192.168.1.1"
      described_class.current_remote_addr = addr
      expect(described_class.current_remote_addr).to eq(addr)
    end
  end

  describe ".transaction_id" do
    before do
      described_class.reset
    end

    it "returns nil initially" do
      expect(described_class.transaction_id).to be_nil
    end

    it "returns set value" do
      id = "txn-123"
      described_class.transaction_id = id
      expect(described_class.transaction_id).to eq(id)
    end
  end

  describe ".transaction_name" do
    before do
      described_class.reset
    end

    it "returns nil initially" do
      expect(described_class.transaction_name).to be_nil
    end

    it "returns set value" do
      name = "GET /api/users"
      described_class.transaction_name = name
      expect(described_class.transaction_name).to eq(name)
    end
  end

  describe ".reset" do
    it "resets all attributes" do
      described_class.current_user = double("User")
      described_class.current_request_uuid = "123-456"
      described_class.current_remote_addr = "192.168.1.1"
      described_class.transaction_id = "txn-123"
      described_class.transaction_name = "GET /api/users"

      described_class.reset

      expect(described_class.current_user).to be_nil
      expect(described_class.current_request_uuid).to be_nil
      expect(described_class.current_remote_addr).to be_nil
      expect(described_class.transaction_id).to be_nil
      expect(described_class.transaction_name).to be_nil
    end
  end
end
