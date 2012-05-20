// A basic connect server with a Convoy asset pipeline to load the main app.
var connect = require('connect');
var convoy  = require('convoy');

var MODE = process.env.NODE_ENV || 'development';

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
    main: './app/main.js',
    minify: (MODE === 'production')
  },

  'app.css': {
    packager: 'css',
    main: './app/main.css'
  },

  'index.html': {
    packager: 'copy',
    root: './app/index.html'
  },

  // generates the HTML5 manifest.
  'app.manifest': {
    packager: require('html5-manifest/packager')
  }

});

// configure a basic application stack. 
var app = connect()
  .use(connect.logger('short'))
  .use(connect.compress()) // keep payload small
  .use(pipeline.middleware())
  .use(connect.errorHandler());

app.listen(3000, function() {
  console.log("Listening on port 3000 in "+MODE+" mode");
});

