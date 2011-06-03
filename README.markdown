Developer Challenge
====================

Task: Build a system that will accept a multipart form upload while displaying a percentage progress
---------------------

This Ruby web app uses Sinatra, for its intuitive routing and rendering functions, EventMachine, to asynchronously handle file uploads and monitor their progress, and jQuery, to parse the streamed progress data and return it to the user. Additionally I chose to run it on Thin, because it’s able to return asynchronous responses and it’s fast.

I was able to achieve a fully asynchronous file upload except  for the initial form submission. To maintain cross-browser compatibility, submitting the upload form actually synchronously POSTs the upload form and renders the response in a hidden iframe. However, the response is asynchronously rendered, emitting the upload percent completion as the file upload progresses, using the EventMachine internal event loop. This is achieved with EM.defer, which is used to push the otherwise blocking operation of File.read onto an EM internal queue whose jobs are then processed by a thread pool of 20 (by default) threads. The file is written to disk in blocks of a set size, and as each block is written, the asynchronous rendering of the upload progress is added to EM’s internal queue with an EM.next_tick block, and it is returned to the user through my javascript function update_progress, which gets the latest rendered percent completion from the iframe roughly every 2 seconds, until the file upload is complete. 

My favorite part about this design is that the process of writing the file is decoupled from getting information about that writing, through EM’s internal event queue. The blocking process of writing a file to the disk is handled by EM’s internal thread pool, while the progress of that file writing is asynchronously rendered from within the file writing process using EM’s internal event queue.

### Install & Run

1. Pull the app from this git repository.
2. Make sure the following gems are installed: sinatra, erubis, eventmachine, json
3. mkdir uploads (in the same folder as app.rb)
4. ruby -rubygems app.rb
5. Profit ([http://0.0.0.0:4567](http://0.0.0.0:4567))