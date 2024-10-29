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
  end

  describe ".context" do
  end

  describe ".reset_context" do
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
