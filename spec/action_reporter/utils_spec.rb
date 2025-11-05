require "spec_helper"

RSpec.describe ActionReporter::Utils do
  describe ".deep_transform_values" do
    it "handles nested hashes" do
      hash = {
        foo: "bar",
        nested: {
          baz: "qux"
        }
      }
      result = described_class.deep_transform_values(hash) { |v| v }
      expect(result).to eq(hash)
    end

    it "handles arrays with hashes" do
      hash = {
        items: [
          {id: 1, name: "item1"},
          {id: 2, name: "item2"}
        ]
      }
      result = described_class.deep_transform_values(hash) { |v| v }
      expect(result).to eq(hash)
    end

    it "handles arrays with nested hashes" do
      hash = {
        items: [
          {nested: {id: 1}},
          {nested: {id: 2}}
        ]
      }
      result = described_class.deep_transform_values(hash) { |v| v }
      expect(result).to eq(hash)
    end

    context "when value has to_global_id" do
      let(:user) { double("User", to_global_id: double("GlobalID", to_s: "gid://user/1")) }

      it "transforms nested hash values" do
        hash = {
          user: user,
          nested: {
            owner: user
          }
        }
        result = described_class.deep_transform_values(hash) { |v| v.respond_to?(:to_global_id) ? v.to_global_id.to_s : v }
        expect(result).to eq({
          user: "gid://user/1",
          nested: {
            owner: "gid://user/1"
          }
        })
      end

      it "transforms array values that are hashes" do
        hash = {
          items: [
            {user: user},
            {user: user}
          ]
        }
        result = described_class.deep_transform_values(hash) { |v| v.respond_to?(:to_global_id) ? v.to_global_id.to_s : v }
        expect(result).to eq({
          items: [
            {user: "gid://user/1"},
            {user: "gid://user/1"}
          ]
        })
      end

      it "transforms nested array hash values" do
        hash = {
          items: [
            {user: user}
          ]
        }
        result = described_class.deep_transform_values(hash) { |v| v.respond_to?(:to_global_id) ? v.to_global_id.to_s : v }
        expect(result).to eq({
          items: [
            {user: "gid://user/1"}
          ]
        })
      end
    end
  end
end
