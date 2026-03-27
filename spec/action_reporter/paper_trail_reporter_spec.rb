require "spec_helper"
require "rails"
require "paper_trail"
require "action_reporter/paper_trail_reporter"

RSpec.describe ActionReporter::PaperTrailReporter do
  subject(:instance) { described_class.new }

  describe "#context" do
    it "does nothing" do
      expect { instance.context({foo: "bar"}) }.not_to raise_error
    end
  end

  describe "#current_user" do
    it "returns current_user from whodunnit" do
      user = double("User", to_global_id: "gid://user/1")
      PaperTrail.request.whodunnit = user
      expect(instance.current_user).to eq(user)
      PaperTrail.request.whodunnit = nil
    end
  end

  describe "#current_user=" do
    before do
      PaperTrail.request.whodunnit = nil
    end

    it "sets current_user", :aggregate_failures do
      user = double("User", to_global_id: "gid://user/1")
      expect(PaperTrail.request.whodunnit).to be_nil
      instance.current_user = user
      expect(PaperTrail.request.whodunnit).to eq(user)
    end
  end

  describe "#reset_context" do
    it "resets context" do
      allow(PaperTrail.request).to receive(:whodunnit=)
      instance.reset_context
      expect(PaperTrail.request).to have_received(:whodunnit=).with(nil)
    end
  end
end
