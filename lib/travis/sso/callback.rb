require 'travis/sso'

module Travis
  module SSO
    class Callback < Generic
      OPTIONAL_CALLBACKS = [:authorized?, :whitelisted?]

      def initialize(app, options = {})
        check = CALLBACKS - OPTIONAL_CALLBACKS
        check.each { |c| raise ArgumentError, "callback #{c} missing" unless options[c] }
      end
    end
  end
end
