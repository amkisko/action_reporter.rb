require "spec_helper"
require "rails"
require "paper_trail"

RSpec.describe ActionReporter::PaperTrailReporter do
  subject(:instance) { described_class.new }

  describe "#notify" do
  end

  describe "#context" do
    it "does nothing" do
      expect { subject.context({foo: "bar"}) }.not_to raise_error
    end
  end

  describe "#current_user" do
    it "returns current_user from whodunnit" do
      user = double("User", to_global_id: "gid://user/1")
      PaperTrail.request.whodunnit = user
      expect(subject.current_user).to eq(user)
      PaperTrail.request.whodunnit = nil
    end
  end

  describe "#current_user=" do
    before do
      PaperTrail.request.whodunnit = nil
    end

    it "sets current_user" do
      user = double("User", to_global_id: "gid://user/1")
      expect(PaperTrail.request.whodunnit).to eq(nil)
      subject.current_user = user
      expect(PaperTrail.request.whodunnit).to eq(user)
    end
  end

  describe "#reset_context" do
    subject(:reset_context) { instance.reset_context }

    it "resets context" do
      expect(PaperTrail.request).to receive(:whodunnit=).with(nil)
      subject
    end
  end
end
