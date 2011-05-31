require 'sinatra'
require 'erubis'

get '/' do
  eruby = Erubis::Eruby.new(File.read('home.rhtml'))
  items = ['foo', 'bar', 'baz']
  return eruby.evaluate(:items => items)
end