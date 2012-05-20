# Ember for Node

Ember.js is a framework for building ambitious client-side applications on the
web. Now you can use the same Ember tools in node code and in node-based asset
pipelines like [Convoy](http://github.com/charlesjolley/convoy).

# Using This Package

Just add ember as a requirement to your package.json:

```javascript
"dependencies": {
  ...
  "ember": "~0.9"
}
```

In your code, you can load the entire Ember stack by just requiring the package.
This will add Ember to the global namespace in your application.

```javascript
require('ember');

MyApp = Ember.Application.create({
  hi: function() { console.log('Hi! I'm an app!'); }
});
```

If you don't want to use the entire Ember stack, you can just require the 
specific module that you want. For example, a lot of server side code just 
needs States for statecharting:

```javascript
require('ember/states');

MyState = Ember.State.create({
  
});
```

# Using Ember with Convoy

Building an Ember application in the browser is very easy when using Convoy.
Just require ember in your main application file.

```javascript
// In some JS module included by convoy:
require('ember'); // <- convoy will automatically pull in all of Ember.

UserView = Ember.View.extend({
  template: Ember.Handlebars.compile('{{firstName}} {{lastName}}')
});
```

If you want to store your Handlebars templates in a separate file, Ember for
Node has a HandlebarsCompiler that will precompile the templates for you. 
Here is an example Convoy pipeline configuration:

```javascript
pipeline = convoy({
  'app.js': {
    packager: 'javascript',
    compilers: {
      '.hbr': require('ember/packager').HandlebarsCompiler
    }
  }
});

app = express.createServer();
app.use(pipeline.middleware());
```

This will now make `.hbr` files available as modules. In your app code, you
can load the template via a normal require:

```javascript
// user_view.js

require('ember/views');

UserView = Ember.View.extend({
  template: require('./user_template') // template in user_template.hbr
});
```

For a fully functioning example of an application, check out the 
[examples](https://github.com/charlesjolley/node-ember/tree/master/examples) 
folder.
