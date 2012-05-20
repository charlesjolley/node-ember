Example using Ember for Node with Convoy to generate a client-side app.
It also uses the html5-manifest plugin and connect.compress() middleware to 
make the app load very fast.

To try this out just do the following:

  1.  `npm install` inside this directory.
  2.  `node server.js` to start the connect server.
  3.  Visit http://localhost:3000/index.html

Next, try this in production mode by starting the server like this:

  `NODE_ENV=production node server.js`

This will rebuild the app with minification. Check the final download sizes
delivered to the browser, both gzipped and afterwards.
  
This code just require ember and convoy does the rest.

