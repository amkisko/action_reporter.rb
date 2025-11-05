require "spec_helper"

RSpec.describe ActionReporter do
  it "has a version number" do
    expect(ActionReporter::VERSION).not_to be nil
  end

  describe ".enabled_reporters" do
    subject(:enabled_reporters) { described_class.enabled_reporters }

    it "returns enabled reporters" do
      expect(subject).to eq([])
    end

    context "when Rails is defined" do
      let(:rails_reporter) { ActionReporter::RailsReporter.new }
      before do
        described_class.enabled_reporters = [
          rails_reporter
        ]
      end
      it "returns enabled reporters" do
        expect(subject).to eq([rails_reporter])
      end
    end
  end

  describe ".notify" do
    let(:reporter) { double("Reporter") }
    let(:error) { StandardError.new("error") }
    let(:context_data) { {foo: "bar"} }

    before do
      described_class.enabled_reporters = [reporter]
    end

    it "calls notify on enabled reporters" do
      expect(reporter).to receive(:respond_to?).with(:notify).and_return(true)
      expect(reporter).to receive(:notify).with(error, context: context_data)
      described_class.notify(error, context: context_data)
    end

    it "skips reporters that don't respond to notify" do
      expect(reporter).to receive(:respond_to?).with(:notify).and_return(false)
      expect(reporter).not_to receive(:notify)
      described_class.notify(error, context: context_data)
    end
  end

  describe ".context" do
    let(:reporter) { double("Reporter") }
    let(:context_data) { {foo: "bar"} }

    before do
      described_class.enabled_reporters = [reporter]
    end

    it "calls context on enabled reporters" do
      expect(reporter).to receive(:respond_to?).with(:context).and_return(true)
      expect(reporter).to receive(:context).with(context_data)
      described_class.context(context_data)
    end

    it "skips reporters that don't respond to context" do
      expect(reporter).to receive(:respond_to?).with(:context).and_return(false)
      expect(reporter).not_to receive(:context)
      described_class.context(context_data)
    end
  end

  describe ".reset_context" do
    let(:reporter) { double("Reporter") }

    before do
      described_class.enabled_reporters = [reporter]
    end

    it "calls reset_context on enabled reporters" do
      expect(reporter).to receive(:respond_to?).with(:reset_context).and_return(true)
      expect(reporter).to receive(:reset_context)
      described_class.reset_context
    end

    it "skips reporters that don't respond to reset_context" do
      expect(reporter).to receive(:respond_to?).with(:reset_context).and_return(false)
      expect(reporter).not_to receive(:reset_context)
      described_class.reset_context
    end
  end

  describe ".check_in" do
    let(:reporter) { double("Reporter") }
    let(:identifier) { "check-in-id" }

    before do
      described_class.enabled_reporters = [reporter]
    end

    it "calls check_in on enabled reporters" do
      expect(reporter).to receive(:respond_to?).with(:check_in).and_return(true)
      expect(reporter).to receive(:check_in).with(identifier)
      described_class.check_in(identifier)
    end

    it "skips reporters that don't respond to check_in" do
      expect(reporter).to receive(:respond_to?).with(:check_in).and_return(false)
      expect(reporter).not_to receive(:check_in)
      described_class.check_in(identifier)
    end
  end

  describe ".current_request_uuid" do
    before do
      described_class.enabled_reporters = []
      described_class.instance_variable_set(:@current_request_uuid, nil)
    end

    it "returns nil initially" do
      expect(described_class.current_request_uuid).to be_nil
    end

    it "returns the set value" do
      uuid = "123-456-789"
      described_class.current_request_uuid = uuid
      expect(described_class.current_request_uuid).to eq(uuid)
    end

    context "when reporter responds to current_request_uuid=" do
      let(:reporter) { double("Reporter") }

      before do
        described_class.enabled_reporters = [reporter]
      end

      it "sets current_request_uuid on reporters" do
        uuid = "123-456-789"
        expect(reporter).to receive(:respond_to?).with(:current_request_uuid=).and_return(true)
        expect(reporter).to receive(:current_request_uuid=).with(uuid)
        described_class.current_request_uuid = uuid
      end
    end
  end

  describe ".current_remote_addr" do
    before do
      described_class.enabled_reporters = []
      described_class.instance_variable_set(:@current_remote_addr, nil)
    end

    it "returns nil initially" do
      expect(described_class.current_remote_addr).to be_nil
    end

    it "returns the set value" do
      addr = "192.168.1.1"
      described_class.current_remote_addr = addr
      expect(described_class.current_remote_addr).to eq(addr)
    end

    context "when reporter responds to current_remote_addr=" do
      let(:reporter) { double("Reporter") }

      before do
        described_class.enabled_reporters = [reporter]
      end

      it "sets current_remote_addr on reporters" do
        addr = "192.168.1.1"
        expect(reporter).to receive(:respond_to?).with(:current_remote_addr=).and_return(true)
        expect(reporter).to receive(:current_remote_addr=).with(addr)
        described_class.current_remote_addr = addr
      end
    end
  end

  describe ".current_user" do
    context "when AuditedReporter is enabled" do
      let(:audited_reporter) { ActionReporter::AuditedReporter.new }
      let(:audited_stub) { double("Audited") }
      before do
        described_class.enabled_reporters = [
          audited_reporter
        ]
        allow(audited_stub).to receive(:store).and_return({current_user: "user"})
        stub_const("Audited", audited_stub)
      end
      let(:new_user) { double("User", to_global_id: "gid://user/1") }

      it "returns current_user" do
        expect { described_class.current_user = new_user }.not_to raise_error
        expect(described_class.current_user).to eq(new_user)
      end
    end
  end
end
