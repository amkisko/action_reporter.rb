require 'spec_helper'
require 'honeybadger'

RSpec.describe ActionReporter::HoneybadgerReporter do
  subject { described_class.new }

  before do
    Honeybadger.configure do |config|

    end
  end

  describe '#notify' do

  end

  describe '#context' do

  end

  describe '#check_in' do
    subject(:check_in) { described_class.new.check_in(identifier) }

    context "when identifier is a string" do

    end

    context "when identifier is a class" do
      let(:reporter_check_in) { "reporter_check_in_test" }
      let(:identifier) { double("User", reporter_check_in: reporter_check_in) }

      before do
        stub_request(:get, "https://api.honeybadger.io/v1/check_in/#{reporter_check_in}").to_return(status: 200, body: "", headers: {})
      end

      it 'returns identifier' do
        expect(Honeybadger).to receive(:check_in).with(reporter_check_in).and_call_original
        subject
      end
    end
  end
end
