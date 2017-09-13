require 'spec_helper'

describe Travis::SSO::Helpers do
  subject { Object.new.extend(Travis::SSO::Helpers) }

  def current_user
    subject.current_user
  end

  describe :user_class do
    after(:each) do
      Travis.send(:remove_const, :User) if defined? Travis::User
      Object.send(:remove_const, :User) if defined? ::User
    end

    it 'defaults to OpenStruct' do
      Travis::SSO::Helpers.user_class.should be == OpenStruct
    end

    it 'picks User if available' do
      User = 42
      Travis::SSO::Helpers.user_class.should be == 42
    end

    it 'picks Travis::User if available' do
      Travis::User = 42
      Travis::SSO::Helpers.user_class.should be == 42
    end
  end

  describe :current_user do
    it 'complains if there is no request info available' do
      expect { current_user }.to raise_error(NameError, /request/)
    end

    it 'takes the user id from session["user_id"]' do
      stub! :session => { 'user_id' => 42 }
      current_user.id.should be == 42
    end

    it 'takes the user id from env["rack.session"]["user_id"]' do
      stub! :env => { 'rack.session' => { 'user_id' => 42 }}
      current_user.id.should be == 42
    end

    it 'takes the user id from request.env["rack.session"]["user_id"]' do
      request = flexmock('request', :env => { 'rack.session' => { 'user_id' => 42 }})
      stub! :request => request
      current_user.id.should be == 42
    end

    it 'takes the user id from env["travis.user_info"]["id"]' do
      stub! :env => { 'travis.user_info' => { 'id' => 42 }}
      current_user.id.should be == 42
    end

    it 'does not complain about a missing user' do
      stub! :env => {}
      current_user.should be_nil
    end

    it 'merges env and session info' do
      stub! :env => {
        'rack.session'     => { 'user_id' => 1337    },
        'travis.user_info' => { 'name'    => 'Klaus' }
      }
      current_user.id.should   be == 1337
      current_user.name.should be == 'Klaus'
    end

    it 'does not set a user without an id' do
      stub! :env => { 'travis.user_info' => { 'name' => 'Klaus' } }
      current_user.should be_nil
    end

    it 'uses Travis::SSO::Helpers.user_class' do
      subclass = Class.new(OpenStruct)
      Travis::SSO::Helpers.should_receive(:user_class).and_return(subclass)

      stub! :session => { 'user_id' => 42 }
      current_user.should be_a(subclass)
    end

    it 'calls find_by_id(id) on the user_class if avaiable' do
      subclass = Class.new
      Travis::SSO::Helpers.should_receive(:user_class).and_return(subclass)
      subclass.should_receive(:find_by_id).with(42).and_return("Klaus")

      stub! :session => { 'user_id' => 42 }
      current_user.should be == "Klaus"
    end
  end

  describe :user do
    it 'calls current_user' do
      stub! :current_user => 42
      subject.user.should be == 42
    end
  end
end
