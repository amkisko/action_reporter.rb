require "spec_helper"

RSpec.describe ActionReporter::Current do
  around do |example|
    original_adapter = described_class.storage_adapter
    described_class.reset_storage_adapter!
    described_class.reset
    example.run
  ensure
    described_class.storage_adapter = original_adapter
    described_class.reset
  end

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
    it "resets all attributes", :aggregate_failures do
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

  describe "execution state storage" do
    it "uses configured storage_adapter when provided", :aggregate_failures do
      adapter = Class.new do
        class << self
          def [](key)
            store[key]
          end

          def []=(key, value)
            store[key] = value
          end

          private

          def store
            @store ||= {}
          end
        end
      end

      described_class.storage_adapter = adapter
      described_class.current_user = "adapter-user"

      expect(described_class.current_user).to eq("adapter-user")
      expect(adapter[:action_reporter_current_user]).to eq("adapter-user")
    end

    it "rejects invalid storage_adapter" do
      expect {
        described_class.storage_adapter = Object.new
      }.to raise_error(ArgumentError, "storage_adapter must respond to #[] and #[]=")
    end

    it "uses ActiveSupport::IsolatedExecutionState when available", :aggregate_failures do
      active_support_module = defined?(ActiveSupport) ? ActiveSupport : Module.new
      fake_state = Class.new do
        class << self
          def [](key)
            store[key]
          end

          def []=(key, value)
            store[key] = value
          end

          private

          def store
            @store ||= {}
          end
        end
      end

      stub_const("ActiveSupport", active_support_module) unless defined?(ActiveSupport)
      stub_const("ActiveSupport::IsolatedExecutionState", fake_state)

      described_class.current_user = "isolated-user"

      expect(described_class.current_user).to eq("isolated-user")
      expect(fake_state[:action_reporter_current_user]).to eq("isolated-user")
    end

    it "prefers configured storage_adapter over ActiveSupport::IsolatedExecutionState", :aggregate_failures do
      active_support_module = defined?(ActiveSupport) ? ActiveSupport : Module.new
      fake_state = Class.new do
        class << self
          def [](key)
            store[key]
          end

          def []=(key, value)
            store[key] = value
          end

          private

          def store
            @store ||= {}
          end
        end
      end

      adapter = Class.new do
        class << self
          def [](key)
            store[key]
          end

          def []=(key, value)
            store[key] = value
          end

          private

          def store
            @store ||= {}
          end
        end
      end

      stub_const("ActiveSupport", active_support_module) unless defined?(ActiveSupport)
      stub_const("ActiveSupport::IsolatedExecutionState", fake_state)
      described_class.storage_adapter = adapter

      described_class.current_user = "adapter-priority"

      expect(described_class.current_user).to eq("adapter-priority")
      expect(adapter[:action_reporter_current_user]).to eq("adapter-priority")
      expect(fake_state[:action_reporter_current_user]).to be_nil
    end
  end
end
