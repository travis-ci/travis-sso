require 'travis/sso'

module Travis
  module SSO
    class Session < Generic
      attr_reader :user_id_key, :session_key

      def initialize(app, options = {})
        @user_id_key = options[:user_id_key] || 'user_id'
        @session_key = options[:session_key] || 'rack.session'
        super
      end

      def pass(request)
        response(303, 'Location' => request.url)
      end

      def set_user(request, user)
        session(request)[user_id_key] = user['id']
      end

      def authenticated?(request)
        session(request).include? user_id_key
      end

      private

        def session(request)
          request.env.fetch(session_key)
        end

        def authenticity_token(request)
          session = session(request)
          session[:csrf] || session['_csrf_token']
        end
    end
  end
end
