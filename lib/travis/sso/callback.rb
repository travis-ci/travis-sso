# frozen_string_literal: true

require 'travis/sso'

module Travis
  module SSO
    class Callback < Generic
      OPTIONAL_CALLBACKS = %i[authorized? whitelisted? get_otp_secret set_otp_secret describe_otp
                              generate_otp_secret].freeze

      def initialize(_app, options = {})
        check = CALLBACKS - OPTIONAL_CALLBACKS
        check.each { |c| raise ArgumentError, "callback #{c} missing" unless options[c] }
        super(app,options)
      end
    end
  end
end
