require 'travis/sso'
use Travis::SSO, mode: :single_page
run -> env { [200, {'Content-Type' => 'text/plain'}, ["Hi, #{env['travis.user_info']['name']}!"]] }
