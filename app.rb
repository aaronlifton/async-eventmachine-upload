require 'rubygems'
require erubis
require sinatra
require json
require rest_client
require active_support
require sinatra/common_helper
require middleware

set :sessions, true
set :show_exceptions, false
use Rack::Flash
use Middleware::App

get '/' do
  eruby = Erubis::Eruby.new(File.read('home.rhtml'))
  items = ['foo', 'bar', 'baz']
  res.body = eruby.evaluate(:items => items)
end


error do  redirect '/' end