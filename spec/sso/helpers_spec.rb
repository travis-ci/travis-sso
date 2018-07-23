require 'spec_helper'

describe Travis::SSO::Helpers do
  subject { Object.new.extend(described_class) }

  let(:current_user) { subject.current_user }

  context 'user_class' do
    after(:each) do
      Travis.send(:remove_const, :User) if defined? Travis::User
      Object.send(:remove_const, :User) if defined? ::User
    end

    it 'defaults to OpenStruct' do
      expect(Travis::SSO::Helpers.user_class).to eq(OpenStruct)
    end

    it 'picks User if available' do
      User = 42
      expect(Travis::SSO::Helpers.user_class).to eq(42)
    end

    it 'picks Travis::User if available' do
      Travis::User = 42
      expect(Travis::SSO::Helpers.user_class).to eq(42)
    end
  end

  describe 'current_user' do
    it 'complains if there is no request info available' do
      expect { current_user }.to raise_error(NameError, /request/)
    end

    it 'takes the user id from session["user_id"]' do
      allow(subject).to receive(:session).and_return({ 'user_id' => 42 })
      expect(current_user.id).to eq(42)
    end

    it 'takes the user id from env["rack.session"]["user_id"]' do
      allow(subject).to receive(:env).and_return({ 'rack.session' => { 'user_id' => 42 }})
      expect(current_user.id).to eq(42)
    end

    it 'takes the user id from request.env["rack.session"]["user_id"]' do
      request = double(:request, :env => { 'rack.session' => { 'user_id' => 42 }})
      allow(subject).to receive(:request).and_return(request)
      expect(current_user.id).to eq(42)
    end

    it 'takes the user id from env["travis.user_info"]["id"]' do
      allow(subject).to receive(:env).and_return({ 'travis.user_info' => { 'id' => 42 }})
      expect(current_user.id).to eq(42)
    end

    it 'does not complain about a missing user' do
      allow(subject).to receive(:env).and_return({})
      expect(current_user).to be_nil
    end

    it 'merges env and session info' do
      allow(subject).to receive(:env).and_return({
        'rack.session'     => { 'user_id' => 1337    },
        'travis.user_info' => { 'name'    => 'Klaus' }
      })
      expect(current_user.id).to eq(1337)
      expect(current_user.name).to eq('Klaus')
    end

    it 'does not set a user without an id' do
      allow(subject).to receive(:env).and_return({ 'travis.user_info' => { 'name' => 'Klaus' } })
      expect(current_user).to be_nil
    end

    it 'uses Travis::SSO::Helpers.user_class' do
      subclass = Class.new(OpenStruct)
      expect(Travis::SSO::Helpers).to receive(:user_class).and_return(subclass)

      allow(subject).to receive(:session).and_return({ 'user_id' => 42 })
      expect(current_user).to be_a(subclass)
    end

    it 'calls find_by_id(id) on the user_class if avaiable' do
      subclass = Class.new
      expect(Travis::SSO::Helpers).to receive(:user_class).and_return(subclass)
      expect(subclass).to receive(:find_by_id).with(42).and_return("Klaus")

      allow(subject).to receive(:session).and_return({ 'user_id' => 42 })
      expect(current_user).to eq("Klaus")
    end
  end

  describe 'user' do
    it 'calls current_user' do
      allow(subject).to receive(:current_user).and_return(42)
      expect(subject.user).to eq(42)
    end
  end
end
