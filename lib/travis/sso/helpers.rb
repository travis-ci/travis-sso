require 'ostruct'

module Travis
  module SSO
    module Helpers
      def current_user
        @current_user ||= begin
          env = send(:env) if respond_to? :env
          env ||= request.env

          user_info = request.env['travis.user_info']
          user_info ||= { 'id' => session['user_id'] }

          if defined? ::User
            ::User.find user_info['id']
          elsif defined? ::Travis::User
            ::Travis::User.find user_info['id']
          else
            OpenStruct.new(user_info)
          end
        end
      end

      def user
        # no alias in case current_user gets overridden
        current_user
      end
    end
  end
end
