require 'spec_helper'

RSpec.describe ActionReporter::HoneybadgerReporter do
  subject { described_class.new }

  let(:honeybadger_stub) { double('Honeybadger') }
  before do
    stub_const('Honeybadger', honeybadger_stub)
  end
end
