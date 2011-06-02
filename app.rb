require 'sinatra'
require 'erubis'
require 'dm-core'
require 'json'
require 'eventmachine'

use Rack::Session::Pool, :expire_after => 2592000

class Upload
  attr_accessor :progress, :file, :id
  
  def initialize(progress,file)
    @progress = progress
    @file = file || Hash.new
    $uploads << self
    @id = $uploads.size
  end
end

class UploadStream
  include EventMachine::Deferrable
  attr_accessor :progress
  
  def initialize(progress)
    @progress = progress || 0
  end
  
  def call(body)
    body.each do |chunk|
      @body_callback.call(chunk)
    end
  end

  def each(&blk)
    @body_callback = blk
  end

  def format_progress
      return "#{@progress.round.to_s}%\n\n"
  end
end

get '/stream' do
  @upload = UploadStream.new(0)
  EventMachine.next_tick do
    request.env['async.callback'].call [
      200, {'Content-Type' => 'text/event-stream'},
      @upload ]
  end
  [-1, {}, []]
end

get '/' do
  eruby = Erubis::Eruby.new(File.read('home.rhtml'))
  items = ['foo', 'bar', 'baz']
  return eruby.evaluate(:items => items)
end

post '/upload' do
  unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
    redirect '/'
  end
  
  @upload = UploadStream.new(0)
  EM.next_tick { env['async.callback'].call [200, {'Content-Type' => 'text/plain'}, @upload] }
  total = tmpfile.size
  path = File.join(Dir.pwd,"uploads", name)
  blocksize = 100
  save_file = proc {
    while block = tmpfile.read(blocksize)#65536
        #t = Thread.new do
          File.open(path, "ab") { |f|
            f.write(block)
            @upload.progress += (((blocksize.to_f)/total.to_f))*100
            EM.next_tick do
              @upload.call @upload.format_progress
            end
          }
    end
  }
  callback = proc { |result|
    @upload.succeed
    session[:filename] = name
    session[:filepath] = path
  }
  EM.defer(save_file,callback)

  
  [-1, {}, []].freeze
  
  #  unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
  #    redirect '/'
  #  end
  #  File.open(File.join(Dir.pwd,"uploads", name), "wb") { |f| f.write(tmpfile.read) }
  #  "sucess"
  #end
end

get '/file_info.json' do
  content_type :json
  { :filename => session[:filename], :filepath => session[:filepath] }.to_json
end