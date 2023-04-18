require 'spec_helper'

RSpec.describe ActionReporter::RailsReporter do
  subject { described_class.new }

  let(:rails_stub) { double('Rails') }
  let(:logger_stub) { double('logger') }
  before do
    stub_const('Rails', rails_stub)
    allow(rails_stub).to receive(:logger).and_return(logger_stub)
  end

  describe '#notify' do
    it 'prints notification' do
      expect(logger_stub).to receive(:info).with(
        "Reporter notification: \"error\", {:foo=>\"bar\"}"
      )
      subject.notify('error', context: { foo: 'bar' })
    end
  end

  describe '#context' do
    it 'prints context' do
      expect(logger_stub).to receive(:info).with("Reporter context: {:foo=>\"bar\"}")
      subject.context({ foo: 'bar' })
    end
  end
end
