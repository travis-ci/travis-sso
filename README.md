# Travis::SSO [![Build Status](https://travis-ci.com/travis-ci/travis-sso.svg?branch=master)](https://travis-ci.com/travis-ci/travis-sso)

Implements Travis CI Single Sign-On as a Rack middleware.

Dependencies are intentionally kept simple (`rack` and `multi_json`), so it fits in whatever stack the app has.

## Usage

If an unauthenticated request is made through this middleware, an authentication handshake with the [Travis API](https://github.com/travis-ci/travis-api) is performed.

Example Usage:

``` ruby
use Travis::SSO,
  mode: :single_page,                 # defaults to :callback
  endpoint: "http://localhost:3000"   # defaults to "https://api.travis-ci.org"
```

### Session Authentication

``` ruby
use Rack::Session::Cookie, secret: 'change_me'
use Travis::SSO, mode: :session
```

Note: Usually Sinatra or Rails will set up the session for you. In either case, make sure the `Travis::SSO` middleware is added *after* the session middleware, otherwise it will not be able to store the user id in the session.

By default, it will store the user id in a session field called `user_id`. You can change that by passing in a `:user_id_key` option:

``` ruby
require 'sinatra'

enable :sessions
use Travis::SSO, mode: :session, user_id_key: 'foo'

helpers do
  def current_user
    @current_user ||= User.find session['foo']
  end
end
```

If you should set up a custom session store besides the standard, you can change the env key used by passing in `:session_key`:

``` ruby
use Rack::Session::Memcache, key: 'my_app.session1', secret: 'change_me'
use Rack::Session::Cookie, key: 'my_app.session2', secret: 'change_me'
use Travis::SSO, mode: :session, session_key: 'my_app.session1'
```

Keep in mind to protect against all these nasty session based attacks if you use this mode.

### Single-Page Authentication

Authenticates a single GET request. Every subsequent GET request (that's going through the middleware) will need to go through the handshake again. This is more secure than session based authentication and is ideal for single page or JavaScript heavy applications.

``` ruby
use Travis::SSO, mode: :single_page
```

### Custom Authentication with Callbacks

This is the default mode. When using this mode, you have to provide a `:pass`, `:set_user` and `:authenticated?` callback.

Each of these takes a `Rack::Request` instance as first argument. In addition, `:set_user` takes a hash with user information as a second argument.

The `:pass` callback will be called after successful login and the return value will be used as response.
The `:set_user` callback will be called to store information about the user for later access.
The `:authenticated?` callback will be called to check if the request is authenticated.

``` ruby
use Travis::SSO,
  pass:           -> r   { [301, {'Location' => '/'}, []]  },
  set_user:       -> r,u { r.session['token'] = u['token'] },
  authenticated?: -> r   { r.session.include? 'token'      }
```

### Whitelisting URLs

``` ruby
use Travis::SSO,
  mode: :single_page,
  whitelist: "/img/*"
```

You can pass in a String, a Regular Expression or an Array of these.

If you need something more fancy, you can also add a `whitelisted?` callback:

``` ruby
use Travis::SSO,
  mode: :single_page,
  whitelisted?: -> r { r.user_agent =~ /Safari/ }
```

### Limiting Users

Optionally, any mode takes an `authorized?` callback you can use to limit user access:

``` ruby
use Travis::SSO,
  mode: :single_page,
  authorized?: -> u { u['login'] == 'dhh' } # let only dhh use this app
```

The hash handed to the callback corresponds to the data returned by [travis-api](https://api.travis-ci.org/docs/#/users/).

### Two-Factor Authentication

The SSO middleware comes with two-factor authentication support built-in.

All you need to do is provide callbacks for storing and retrieving a secret value per user:

``` ruby
secrets = {} # storing secrets in memory, not a good idea

use Travis::SSO,
  mode: :single_page,
  get_otp_secret: -> user { secrets[user['login']] },
  set_otp_secret: -> user, secret { secrets[user['login']] = secret }
```

There are two additional callbacks: `describe_otp(request, user)` to generate the service description and `generate_otp_secret(user)` to override how the secret is generated.

Note that it currently does not support sending out text messages, you will have to use an application like Google Authenticator.

### Helpers

This library ships with a simple helpers mixin, implementing a `current_user` method and aliasing it to `user`. It should work for both Rails controllers and Sinatra applications.

``` ruby
class HomeController < ApplicationController
  # assuming you use Travis::SSO as middleware
  include Travis::SSO::Helpers

  def index
    render text: "Hello, #{user.name}"
  end
end
```

### In Sinatra

`Travis::SSO` can also be used as an Sinatra extension, in which case it will automatically pick session based or single page authentication depending on whether sessions have been enabled and will automatically pull in the helper methods.

Usage is pretty straight forward:

``` ruby
register Travis::SSO

get '/' do
  "Hello, #{user.name}!"
end
```

The middleware can be configured via the `sso` setting:

``` ruby
set :sso, whitelist: "/img/*"
register Travis::SSO

get '/' do
  "Hello, #{user.name}!"
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
