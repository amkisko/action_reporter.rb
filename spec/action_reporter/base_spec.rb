require "spec_helper"

RSpec.describe ActionReporter::Base do
  subject(:instance) { described_class.new }

  describe ".class_accessor" do
    let(:test_class) { Class.new(ActionReporter::Base) }

    before do
      test_class.class_accessor "NonExistent", gem_spec: "nonexistent (~> 1.0)"
    end

    it "raises error when class is not defined" do
      instance = test_class.new
      expect {
        instance.nonexistent_class
      }.to raise_error(ActionReporter::Error, "NonExistent is not defined")
    end

    context "when class is defined" do
      before do
        stub_const("NonExistent", Class.new)
      end

      it "returns the class when it exists, regardless of gem version" do
        instance = test_class.new
        expect(instance.nonexistent_class).to eq(NonExistent)
      end
    end
  end

  describe "#resolve_check_in_id" do
    context "when identifier doesn't respond to reporter_check_in or to_s" do
      let(:identifier) { Object.new }

      before do
        allow(identifier).to receive(:respond_to?).with(:reporter_check_in).and_return(false)
        allow(identifier).to receive(:respond_to?).with(:to_s).and_return(false)
      end

      it "raises ActionReporter::Error" do
        expect {
          instance.resolve_check_in_id(identifier)
        }.to raise_error(ActionReporter::Error, /Unknown check-in identifier/)
      end
    end
  end

  describe "#transform_context" do
    it "handles nested hashes" do
      context = {
        foo: "bar",
        nested: {
          baz: "qux"
        }
      }
      result = instance.transform_context(context)
      expect(result).to eq(context)
    end

    context "when value has to_global_id" do
      let(:user) { double("User", to_global_id: double("GlobalID", to_s: "gid://user/1")) }

      it "transforms to global id string" do
        context = {user: user}
        result = instance.transform_context(context)
        expect(result).to eq({user: "gid://user/1"})
      end
    end
  end

  describe "#transaction_id=" do
    it "does nothing" do
      expect { instance.transaction_id = "txn-123" }.not_to raise_error
    end
  end

  describe "#transaction_name=" do
    it "does nothing" do
      expect { instance.transaction_name = "TestTransaction" }.not_to raise_error
    end
  end
end
