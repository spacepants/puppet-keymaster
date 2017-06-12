require 'spec_helper_acceptance'

describe 'profiles class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'is expected to work idempotently with no errors' do
      pp = <<-EOS
      class { 'profiles': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('profiles') do
      it { is_expected.to be_installed }
    end

    describe service('profiles') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
