Developer Challenge
====================

Task: Build a system that will accept a multipart form upload while displaying a percentage progress
---------------------

This Ruby web app requires Sinatra, EventMachine, jQuery, and a webserver that supports asynchronous requests like Thin.

I was able to achieve a fully asynchronous file upload except for the initial form submission. To maintain cross-browser compatibility, submitting the upload form actually synchronously POSTs the upload form and renders the response in a hidden iframe. However, the response is asynchronously rendered, emitting the upload percent completion as the file upload progresses, using the EventMachine internal event loop. This is achieved with EM.defer, which is used to push the otherwise blocking operation of writing a file onto an EM internal queue whose jobs are then processed by a thread pool of 20 (by default) threads. The file is written to disk in blocks of a set size, and as each block is written, the asynchronous rendering of the upload progress is added to EM’s internal queue with an EM.next_tick block, and it is returned to the user through my javascript function update_progress, which gets the latest rendered percent completion of the upload from the iframe roughly every 2 seconds, until the file upload is complete. 

### How to run

1. Make sure the following gems are installed: sinatra, erubis, eventmachine, json
2. mkdir uploads (in the same folder as app.rb)
3. ruby -rubygems app.rb
4. Profit ([http://0.0.0.0:4567](http://0.0.0.0:4567))

View online: [http://blazing-stream-898.heroku.com](http://blazing-stream-898.heroku.com/) (Note: because it's hosted on heroku, the file is only uploaded to a temporary folder, so you can view the progress of the upload, but you can't actually view the file uploaded.