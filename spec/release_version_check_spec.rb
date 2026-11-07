# frozen_string_literal: true

require "spec_helper"
require "stringio"
require "tmpdir"
require_relative "../usr/lib/release_version_check"

RSpec.describe ReleaseVersionCheck do
  describe ".confirm_release?" do
    it "declines when input is closed" do
      expect(described_class.confirm_release?(input: StringIO.new)).to be false
    end

    it "accepts an entered default answer" do
      expect(described_class.confirm_release?(input: StringIO.new("\n"))).to be true
    end

    it "accepts a lowercase confirmation" do
      expect(described_class.confirm_release?(input: StringIO.new("y\n"))).to be true
    end

    it "accepts an uppercase confirmation" do
      expect(described_class.confirm_release?(input: StringIO.new("Y\n"))).to be true
    end

    it "declines a negative answer" do
      expect(described_class.confirm_release?(input: StringIO.new("n\n"))).to be false
    end
  end

  describe ".changelog_includes_version?" do
    it "accepts plain and Keep a Changelog headings", :aggregate_failures do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "CHANGELOG.md")
        File.write(path, <<~MD)
          # CHANGELOG
          ## 3.2.2 (2026-11-03)
          ## [1.2.3] - 2026-01-01
          ## 9.9.9 (Unreleased)
        MD

        expect(described_class.changelog_includes_version?("3.2.2", path: path)).to be(true)
        expect(described_class.changelog_includes_version?("1.2.3", path: path)).to be(true)
        expect(described_class.changelog_includes_version?("9.9.9", path: path)).to be(false)
        expect(described_class.changelog_includes_version?("0.0.1", path: path)).to be(false)
      end
    end
  end

  describe ".require_changelog_version!" do
    it "aborts when the changelog heading is missing" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "CHANGELOG.md")
        File.write(path, "# CHANGELOG\n## 1.0.0\n")

        expect {
          described_class.require_changelog_version!(version: "3.2.2", path: path)
        }.to raise_error(SystemExit)
      end
    end

    it "passes when the changelog heading is present" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "CHANGELOG.md")
        File.write(path, "# CHANGELOG\n## 3.2.2 (2026-11-03)\n")

        expect {
          described_class.require_changelog_version!(version: "3.2.2", path: path)
        }.not_to raise_error
      end
    end
  end
end
