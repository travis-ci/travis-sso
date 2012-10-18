require 'spec_helper'

describe Travis::SSO do
  describe 'as middleware' do
    let(:callbacks) do
      { :pass => proc {}, :set_user => proc {}, :authenticated? => proc {} }
    end

    it 'maps session mode to Travis::SSO::Session' do
      Travis::SSO.new(nil, :mode => :session).should be_a(Travis::SSO::Session)
    end

    it 'maps single_page mode to Travis::SSO::SinglePage' do
      Travis::SSO.new(nil, :mode => :single_page).should be_a(Travis::SSO::SinglePage)
    end

    it 'maps callback mode to Travis::SSO::Session' do
      Travis::SSO.new(nil, callbacks.merge(:mode => :callback)).should be_a(Travis::SSO::Callback)
    end

    it 'defaults to callback mode' do
      Travis::SSO.new(nil, callbacks).should be_a(Travis::SSO::Callback)
    end

    it 'raises if neither mode nor callbacks are given' do
      expect { Travis::SSO.new(nil) }.to raise_error(IndexError)
    end
  end

  describe 'as Sinatra extension' do
    let(:app) { Sinatra.new { register Travis::SSO } }
    let(:middleware) { app.middleware.map(&:first) }

    it 'pulls in helpers' do
      app.ancestors.should include(Travis::SSO::Helpers)
    end

    it 'sets up the middleware' do
      middleware.should include(Travis::SSO)
    end

    it 'defaults to single_page mode' do
      Travis::SSO::SinglePage.should_receive(:new).once.pass_thru
      app.new
    end

    it 'chooses session mode if sessions are enabled' do
      Travis::SSO::SinglePage.should_receive(:new).never
      Travis::SSO::Session.should_receive(:new).once.pass_thru
      app.enable :sessions
      app.new
    end
  end
end
