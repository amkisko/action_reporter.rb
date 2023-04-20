require 'spec_helper'
require 'scout_apm'

RSpec.describe ActionReporter::ScoutApmReporter do
  subject(:instance) { described_class.new }

  describe '#notify' do
    subject(:notify) { instance.notify(error, context: context_data) }

    let(:error) { StandardError.new('error') }
    let(:context_data) { { foo: 'bar' } }

    it 'sets context' do
      expect(ScoutApm::Context).to receive(:add).with(context_data).and_call_original
      subject
    end

    it 'captures error' do
      expect(ScoutApm::Error).to receive(:capture).with(error).and_call_original
      subject
    end
  end

  describe '#context' do
    subject(:context) { instance.context(context_data) }

    let(:context_data) { { foo: 'bar' } }

    it 'sets context' do
      expect(ScoutApm::Context).to receive(:add).with(context_data).and_call_original
      subject
    end

    it 'transforms context' do
      expect(instance).to receive(:transform_context).with(context_data).and_call_original
      subject
    end
  end

  describe '#reset_context' do

  end

  describe '#audited_user=' do
    subject(:audited_user=) { instance.audited_user = user }

    let(:user) { double('User', to_global_id: 'gid://user/1') }

    it 'sets audited_user' do
      expect(ScoutApm::Context).to receive(:add_user).with({ user_global_id: user.to_global_id }).and_call_original
      subject
    end
  end
end
