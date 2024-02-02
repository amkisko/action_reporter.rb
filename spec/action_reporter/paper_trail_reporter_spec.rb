require 'spec_helper'
require 'rails'
require 'paper_trail'

RSpec.describe ActionReporter::PaperTrailReporter do
  subject(:instance) { described_class.new }

  describe '#notify' do

  end

  describe '#context' do

  end

  describe '#audited_user=' do
    subject(:audited_user=) { instance.audited_user = user }

    let(:user) { double('User', to_global_id: 'gid://user/1') }

    it 'sets audited_user' do
      expect(PaperTrail.request.whodunnit).to eq(nil)
      subject
      expect(PaperTrail.request.whodunnit).to eq(user)
    end
  end

  describe '#reset_context' do
    subject(:reset_context) { instance.reset_context }

    it 'resets context' do
      expect(PaperTrail.request).to receive(:whodunnit=).with(nil)
      subject
    end
  end
end
