require 'travis/sso'

require 'rack/request'
require 'rack/file'
require 'rack/conditionalget'

require 'multi_json'
require 'open-uri'
require 'rotp'

module Travis
  module SSO
    class Generic
      WHITELIST = ['/favicon.ico']
      CALLBACKS = [:pass, :set_user, :authenticated?, :authorized?, :whitelisted?,
                  :get_otp_secret, :set_otp_secret, :describe_otp, :generate_otp_secret]
      attr_reader :app, :endpoint, :files, :login_page, :otp_page, :setup_page, :accept, :whitelist, :use_otp
      alias use_otp? use_otp

      def initialize(app, options = {})
        @app           = app
        @endpoint      = options[:endpoint]       || "https://api.travis-ci.org"
        @accept        = options[:accept]         || 'application/vnd.travis-ci.2+json'
        static_dir     = options[:static_dir]     || File.expand_path('../public',     __FILE__)
        template       = options[:template]       || File.expand_path('../login.html', __FILE__)
        otp_template   = options[:otp_template]   || File.expand_path('../otp.html', __FILE__)
        setup_template = options[:setup_template] || File.expand_path('../setup.html', __FILE__)
        static         = Rack::File.new(static_dir, 'public, must-revalidate')
        @files         = Rack::ConditionalGet.new(static)
        @login_page    = File.read(template).gsub('%endpoint%', endpoint)
        @otp_page      = File.read(otp_template)
        @setup_page    = File.read(setup_template)
        @whitelist     = WHITELIST + Array(options[:whitelist])
        @use_otp       = !!options[:get_otp_secret]

        if options.include?(:get_otp_secret) ^ options.include?(:set_otp_secret)
          raise ArgumentError, "to enable two-factor auth, set both get_otp_secret and set_otp_secret"
        end

        CALLBACKS.each do |callback|
          define_singleton_method(callback, options[callback]) if options.include? callback
        end
      end

      def call(env)
        request = Rack::Request.new(env)
        whitelisted(request) || static(request) || login(request) || handshake(request) || allow(request)
      end

      protected

        def pass(request)
          raise NotImplementedError, 'subclass responsibility'
        end

        def set_user(request, user)
          raise NotImplementedError, 'subclass responsibility'
        end

        def authenticated?(request)
          raise NotImplementedError, 'subclass responsibility'
        end

        def authorized?(user)
          true
        end

        def whitelisted?(request)
          whitelist.any? do |pattern|
            if pattern.respond_to? :to_str
              File.fnmatch?(pattern.to_str, request.path_info)
            else
              pattern === request.path_info
            end
          end
        end

        def describe_otp(request, user)
          "#{request.host}: #{user['login']}"
        end

        def generate_otp_secret(user)
          ROTP::Base32.random_base32
        end

      private

        def whitelisted(request)
          allow(request) if whitelisted? request
        end

        def static(request)
          return unless request.path_info =~ %r[^(/?__travis__)(/.*)$]
          env = request.env.merge('SCRIPT_NAME' => request.script_name + $1, 'PATH_INFO' => $2)
          files.call(env)
        end

        def allow(request)
          app.call(request.env)
        end

        def login(request)
          return unless token = sso_token(request)
          raw  = open("#{endpoint}/users?access_token=#{token}", 'Accept' => accept)
          data = MultiJson.decode(raw.read)
          user = data['user'].merge('token' =>  token)

          if authorized?(user)
            if result = otp(user, request)
              result
            else
              set_user(request, user)
              pass(request)
            end
          else
            response(403, "access denied for #{user['login']}", "Content-Type" => "text/plain")
          end
        rescue OpenURI::HTTPError => error
          response(error.io.read, Integer(error.message[/40\d/] || 403))
        rescue EOFError
        end

        def sso_token(request)
          params = params(request)
          params.fetch('sso_token') { params['token'] if params.include? 'user' }
        end

        def params(request)
          params = request.params if request.post?
          params || {}
        end

        def handshake(request)
          return if authenticated?(request)
          if request.head? or request.get?
            template(login_page, request)
          else
            response(405, "must be <a href='#{request.url}'>GET</a> request", 'Allow' => 'GET, HEAD')
          end
        end

        def otp(user, request)
          return unless use_otp?
          secret = get_otp_secret(user)
          otp    = params(request)['otp'].to_i
          if secret
            totp = ROTP::TOTP.new(secret)
            template(otp_page, request, user) unless totp.verify(otp)
          else
            secret  = params(request)['otp_secret'] || generate_otp_secret(user)
            totp    = ROTP::TOTP.new(secret)
            otp_url = totp.provisioning_uri(describe_otp(request, user))
            qr_img  = "https://chart.googleapis.com/chart?chs=200x200&chld=M|0&cht=qr&chl=#{Rack::Utils.escape(otp_url)}"
            if totp.verify(otp)
              set_otp_secret(user, secret)
              nil
            else
              template(setup_page, request, user, otp_secret: secret, otp_url: otp_url, qr_img: qr_img)
            end
          end
        end

        def template(content, request, *replace)
          replace.unshift(public: File.join(request.script_name, '__travis__'), origin: "#{request.scheme}://#{request.host_with_port}")
          replace.each { |m| m.each { |k,v| content = content.gsub("%#{k}%", v.to_s) } }
          response content
        end

        def response(*args)
          body    = args.grep(String)
          status  = args.grep(Integer).first       || 200
          headers = args.grep(Hash).inject(:merge) || {}
          headers['Content-Type']   ||= 'text/html'
          headers['Content-Length'] ||= body.join.bytesize.to_s
          [status, headers, body]
        end
    end
  end
end
