# frozen_string_literal: true

module Travis
  module SSO
    class Test < Session
      class << self
        attr_reader :user

        def sign_in(user)
          @user ||= user
        end

        def sign_out
          @user = nil
        end
      end

      def authenticated?(_request)
        !!self.class.user
      end

      def allow(request)
        set_user(request, self.class.user) if self.class.user
        super
      end
    end
  end
end
