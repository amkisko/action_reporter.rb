require 'spec_helper'
require 'scout_apm'

RSpec.describe ActionReporter::ScoutApmReporter do
  subject { described_class.new }

  let(:agent_stub) { double('ScoutApm::Agent') }
  let(:context_stub) { double('ScoutApm::Context') }
  before do
    stub_const('ScoutApm::Agent', agent_stub)
    stub_const('ScoutApm::Context', context_stub)
  end
end
