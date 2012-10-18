require 'travis/sso'

module Travis
  module SSO
    class Callback < Generic
      CALLBACKS = [:pass, :set_user, :authenticated?]
      def initialize(app, options = {})
        CALLBACKS.each { |c| define_singleton_method c, options.fetch(c) }
      end
    end
  end
end
