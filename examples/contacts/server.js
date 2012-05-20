// A basic connect server with a Convoy asset pipeline to load the main app.
var connect = require('connect');
var convoy  = require('convoy');

// asset pipeline
var pipeline = convoy({
  watch: true,

  'app.js': {
    packager: 'javascript',
    compilers: {
      '.hbr': require('../../packager').HandlebarsCompiler,
      '.js':  convoy.plugins.JavaScriptCompiler,
      '.coffee': convoy.plugins.CoffeeScriptCompiler
    },
    main: './app/main.js'
  },

  'app.css': {
    packager: 'css',
    main: './app/main.css'
  },

  'index.html': {
    packager: 'copy',
    root: './app/index.html'
  }

});

var app = connect();
app.use(pipeline.middleware());
app.listen(3000, function() {
  console.log("Listening on port 3000");
});

