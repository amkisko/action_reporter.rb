require "spec_helper"
require "rails"

RSpec.describe ActionReporter::RailsReporter do
  subject(:instance) { described_class.new }

  let(:logger_stub) { instance_double("Logger") }
  before do
    Rails.logger = logger_stub
  end

  describe "#notify" do
    it "prints notification" do
      expect(logger_stub).to receive(:info).with(
        match(/Reporter notification: "error", \{(:foo=>|foo: )"bar"\}/)
      )
      subject.notify("error", context: {foo: "bar"})
    end
  end

  describe "#context" do
    it "prints context" do
      expect(logger_stub).to receive(:info).with(match(/Reporter context: \{(:foo=>|foo: )"bar"\}/))
      subject.context({foo: "bar"})
    end
  end

  describe "#transform_context" do
    subject(:transform_context) { described_class.new.transform_context(context) }
    let(:context) { {foo: "bar"} }

    it "returns context" do
      expect(subject).to eq(context)
    end

    context "when context contains current_user" do
      let(:context) { {foo: "bar", current_user: "user"} }

      it "returns context without current_user" do
        expect(subject).to eq({current_user: "user", foo: "bar"})
      end
    end

    context "when context contains ActiveRecord object" do
      let(:context) { {foo: "bar", user: user} }
      let(:user) { double("User", to_global_id: "gid://user/1") }
      it "returns context with global id" do
        expect(subject).to eq({foo: "bar", user: "gid://user/1"})
      end
    end
  end

  describe "#reset_context" do
    it "does nothing" do
      expect { subject.reset_context }.not_to raise_error
    end
  end

  describe "#check_in" do
    let(:identifier) { double("Identifier", reporter_check_in: "check-in-id") }

    it "resolves check_in id and logs it" do
      expect(logger_stub).to receive(:info).with("Reporter check-in: check-in-id")
      subject.check_in(identifier)
    end

    context "when identifier is a string" do
      let(:identifier) { "check-in-id" }

      it "logs the string" do
        expect(logger_stub).to receive(:info).with("Reporter check-in: check-in-id")
        subject.check_in(identifier)
      end
    end
  end
end
