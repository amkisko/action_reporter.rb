require 'spec_helper'
require 'rails'
require 'audited'

RSpec.describe ActionReporter::AuditedReporter do
  subject(:instance) { described_class.new }

  describe '#notify' do

  end

  describe '#context' do

  end

  describe '#reset_context' do
    subject(:reset_context) { instance.reset_context }

    it 'resets context' do
      expect(Audited.store).to receive(:delete).with(:current_remote_address)
      expect(Audited.store).to receive(:delete).with(:audited_user)
      subject
    end
  end
end
