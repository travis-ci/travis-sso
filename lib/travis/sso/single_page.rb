require 'travis/sso'
require 'stringio'

module Travis
  module SSO
    class SinglePage < Generic
      CLEAN_ENV = {
        'REQUEST_METHOD' => 'GET',
        'rack.input'     => StringIO.new,
        'CONTENT_LENGTH' => "0",
        'CONTENT_TYPE'   => ""
      }

      def pass(request)
        app.call request.env.merge(CLEAN_ENV)
      end

      def set_user(request, user)
        request.env['travis.user_info'] = user
      end

      def authenticated?(request)
        request.env.include? 'travis.user_info'
      end
    end
  end
end
