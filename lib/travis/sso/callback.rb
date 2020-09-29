require 'travis/sso'

module Travis
  module SSO
    class Callback < Generic
      OPTIONAL_CALLBACKS = [:authorized?, :whitelisted?, :get_otp_secret, :set_otp_secret, :describe_otp, :generate_otp_secret]

      def initialize(app, options = {})
        check = CALLBACKS - OPTIONAL_CALLBACKS
        check.each { |c| raise ArgumentError, "callback #{c} missing" unless options[c] }
      end
    end
  end
end
