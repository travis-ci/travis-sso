module Travis
  module SSO
    autoload :Callback,   'travis/sso/callback'
    autoload :Generic,    'travis/sso/generic'
    autoload :Helpers,    'travis/sso/helpers'
    autoload :Session,    'travis/sso/session'
    autoload :Test,       'travis/sso/test'
    autoload :SinglePage, 'travis/sso/single_page'

    def self.new(app, options = nil)
      options ||= {}
      yield options if block_given?
      mode = options[:mode] || 'callback'
      name = mode.to_s.split('_').map(&:capitalize).join
      const_get(name).new(app, options)
    end

    # avoid pulling in constants on extend
    def self.extend_object(*)
    end

    # this is called by sinatra when used as extension
    def self.registered(app)
      app.helpers(Helpers)
      settings = app.settings.sso if app.settings.respond_to?(:sso)
      app.use(self, settings) { |c| c[:mode] = app.sessions? ? :session : :single_page }
    end
  end
end
