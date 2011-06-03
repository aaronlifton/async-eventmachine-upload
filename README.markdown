Developer Challenge
====================

Task: Build a system that will accept a multipart form upload while displaying a percentage progress
---------------------

This relatively simple web app uses Sinatra, for ease of routing and rendering, EventMachine, to asynchronously handle file uploads and monitor their progress, and jQuery, to parse the streamed progress data and return it to the user in an intuitive way.

This app achieves an upload that appears asynchronous to the user, but to maintain cross-browser compatablity, it actually synchronously submits the form to an iframe, where the response is asynchronously rendered using EventMachine. EventMachine's mechanism for lightweight concurrency, EM.defer, utilizes a thread pool of 20 Ruby threads (by default) to  achieve lightweight concurrency. This function, along with the EM::Deferrable mixin module, allows this app to return progress data to the user every time data is written to the file, while preventing blocking causes by IO operations such as File.read.

### Install & Run

1. Pull the app from this git repository.
2. Make sure the following gems are installed: sinatra, erubis, eventmachine, json
3. ruby -rubygems app.rb
4. Profit ([http://0.0.0.0:4567](http://0.0.0.0:4567))