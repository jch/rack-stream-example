require 'rubygems'
require 'bundler/setup'

require 'rack/stream'

class App
  include Rack::Stream::DSL

  def call(env)
    after_open do
      count = 0
      EM.add_periodic_timer(1) do
        if count != 3
          chunk "chunky #{count}\n"
          count += 1
        else
          # Connection isn't closed until #close is called.
          # Useful if you're building a firehose API
          close
        end
      end
    end

    before_close do
      chunk "monkey!\n"
    end

    [200, {'Content-Type' => 'application/json'}, []]
  end
end

app = Rack::Builder.app do
  use Rack::Stream
  run App
end

run app
