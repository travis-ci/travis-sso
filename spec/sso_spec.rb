require 'spec_helper'
require 'ostruct'

describe Travis::SSO do
  describe 'as middleware' do
    let(:callbacks) do
      { :pass => proc {}, :set_user => proc {}, :authenticated? => proc {} }
    end

    it 'maps session mode to Travis::SSO::Session' do
      expect(Travis::SSO.new(nil, :mode => :session)).to be_a(Travis::SSO::Session)
    end

    it 'maps single_page mode to Travis::SSO::SinglePage' do
      expect(Travis::SSO.new(nil, :mode => :single_page)).to be_a(Travis::SSO::SinglePage)
    end

    it 'maps callback mode to Travis::SSO::Session' do
      expect(Travis::SSO.new(nil, callbacks.merge(:mode => :callback))).to be_a(Travis::SSO::Callback)
    end

    it 'defaults to callback mode' do
      expect(Travis::SSO.new(nil, callbacks)).to be_a(Travis::SSO::Callback)
    end

    it 'raises if neither mode nor callbacks are given' do
      expect { Travis::SSO.new(nil) }.to raise_error(ArgumentError)
    end
  end

  describe 'whitelisted routes' do
    let(:request) { OpenStruct.new(path_info: '/foo/bar', env: {}) }
    let(:app) { proc { |e| } }

    it 'pipes white listed routes right through' do
      sso = Travis::SSO::Generic.new(app, whitelist: '/foo/bar')
      expect(app).to receive(:call).once
      sso.send(:whitelisted, request)
    end

    it 'accepts patterns' do
      sso = Travis::SSO::Generic.new(app, whitelist: '/foo/*')
      expect(app).to receive(:call).once
      sso.send(:whitelisted, request)
    end

    it 'accepts regexps' do
      sso = Travis::SSO::Generic.new(app, whitelist: /foo/)
      expect(app).to receive(:call).once
      sso.send(:whitelisted, request)
    end

    it 'accepts arrays' do
      sso = Travis::SSO::Generic.new(app, whitelist: ['/bar', /foo/])
      expect(app).to receive(:call).once
      sso.send(:whitelisted, request)
    end

    it 'reject non-matching routes' do
      sso = Travis::SSO::Generic.new(app, whitelist: '/foo')
      expect(app).to_not receive(:call)
      sso.send(:whitelisted, request)
    end
  end

  describe 'as Sinatra extension' do
    let(:app) { Sinatra.new { register Travis::SSO } }
    let(:middleware) { app.middleware.map(&:first) }

    it 'pulls in helpers' do
      expect(app.ancestors).to include(Travis::SSO::Helpers)
    end

    it 'sets up the middleware' do
      expect(middleware).to include(Travis::SSO)
    end

    it 'defaults to single_page mode' do
      expect(Travis::SSO::SinglePage).to receive(:new).once.and_call_original
      app.new
    end

    it 'chooses session mode if sessions are enabled' do
      expect(Travis::SSO::SinglePage).to_not receive(:new)
      expect(Travis::SSO::Session).to receive(:new).once.and_call_original
      app.enable :sessions
      app.new
    end
  end
end
