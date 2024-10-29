require 'spec_helper'
require 'rails'
require 'audited'

RSpec.describe ActionReporter::AuditedReporter do
  subject(:instance) { described_class.new }

  describe '#notify' do

  end

  describe '#context' do

  end

  describe '#current_user=' do
    subject(:current_user=) { instance.current_user = user }

    let(:user) { double('User', to_global_id: 'gid://user/1') }

    it 'sets current_user' do
      expect(Audited.store[:current_user]).to eq(nil)
      subject
      expect(Audited.store[:current_user]).to eq(user)
    end
  end

  describe '#reset_context' do
    subject(:reset_context) { instance.reset_context }

    it 'resets context' do
      expect(Audited.store).to receive(:delete).with(:current_remote_address)
      expect(Audited.store).to receive(:delete).with(:current_request_uuid)
      expect(Audited.store).to receive(:delete).with(:current_user)
      subject
    end
  end
end
