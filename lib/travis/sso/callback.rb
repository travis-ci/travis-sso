require 'travis/sso'

module Travis
  module SSO
    class Callback < Generic
      def initialize(app, options = {})
        CALLBACKS.each { |c| raise ArgumentError, "callback #{c} missing" unless options[c] }
      end
    end
  end
end
