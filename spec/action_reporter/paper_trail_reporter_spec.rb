require 'spec_helper'
require 'rails'
require 'paper_trail'

RSpec.describe ActionReporter::PaperTrailReporter do
  subject(:instance) { described_class.new }

  describe '#notify' do

  end

  describe '#context' do

  end

  describe '#current_user=' do
    subject(:current_user=) { instance.current_user = user }

    let(:user) { double('User', to_global_id: 'gid://user/1') }

    it 'sets current_user' do
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
