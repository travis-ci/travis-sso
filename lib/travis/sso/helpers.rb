require 'ostruct'

module Travis
  module SSO
    module Helpers
      def self.user_class
        return ::User         if defined? ::User
        return ::Travis::User if defined? ::Travis::User
        OpenStruct
      end

      def current_user
        # Implements all these (and more) in one method:
        #
        #     @current_user ||= Travis::User.find session['user_id']
        #     @current_user ||= User.find request.env['rack.session']['user_id']
        #     @current_user ||= OpenStruct.new env['travis.user_info]
        #     @current_user ||= User.find env['travis.user_info']['id']
        #
        # Basically any combination of these is covered
        @current_user ||= begin
          env           = send(:env)      if respond_to? :env
          session       = send(:session)  if respond_to? :session
          env         ||= request.env     if respond_to? :request or not session
          env         ||= {}
          session     ||= env['rack.session']     || {}
          user_info     = env['travis.user_info'] || {}
          user_id       = user_info['id']         ||= session['user_id']
          user_class    = Travis::SSO::Helpers.user_class
          user_class.respond_to?(:find_by_id) ? user_class.find_by_id(user_id) : user_class.new(user_info) if user_id
        end
      end

      def user
        # no alias in case current_user gets overridden
        current_user
      end
    end
  end
end
