require 'rubygems'
require 'bundler/setup'

require 'rack/stream'

class App
  include Rack::Stream::DSL

  stream do
    after_open do
      count = 0
      @timer = EM.add_periodic_timer(1) do
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
      @timer.cancel
      chunk "monkey!\n"
    end

    [200, {'Content-Type' => 'text/plain'}, []]
  end
end

app = Rack::Builder.app do
  use Rack::Stream
  run App.new
end

run app
